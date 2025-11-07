import Foundation

struct ZoneCheckedState {
    var pending: Set<Int> = []      // 로컬 선반영 (서버 미확정)
    var confirmed: Set<Int> = []    // 서버 확정(오늘)
}

final class ZoneCheckedStateManager: ObservableObject {
    static let shared = ZoneCheckedStateManager()

    @Published private(set) var state = ZoneCheckedState()
    // 뷰 강제 업데이트 트리거용 토큰 (예: .id(version) 갱신)
    @Published var version = UUID()

    private let pendingKey = "zone_checked_pending_ids"
    private var previousEffective: Set<Int> = []

    private init() {
        loadPendingFromStorage()
    }

    // MARK: - Public APIs
    /// 낙관적 업데이트: 즉시 pending에 추가 후 서버에 보고
    func onComplete(zoneId: Int, after: ((Bool) -> Void)? = nil) {
        if state.pending.contains(zoneId) || state.confirmed.contains(zoneId) {
            after?(true)
            return
        }

        onMainSync {
            self.state.pending.insert(zoneId)
            self.persistPendingToStorage()
            self.propagateToStatusManager()
        }

        ZoneCheckedService.shared.postChecked(zoneId: zoneId) { [weak self] ok in
            guard let self else { return }
            self.onMainAsync {
                if ok {
                    self.state.pending.remove(zoneId)
                    self.persistPendingToStorage()
                } else {
                    // 실패 시 pending 유지 → 이후 flushPending에서 재시도
                }
                self.propagateToStatusManager()
                after?(ok)
            }
        }
    }

    /// 새 로그인/계정 전환 시, 로컬에 캐시된 완료 구역 상태를 전부 초기화합니다.
    func resetAll() {
        onMainSync {
            // 내부 상태 초기화
            self.state = ZoneCheckedState()
            self.previousEffective = []
            // 저장소 초기화
            UserDefaults.standard.removeObject(forKey: self.pendingKey)
            // 사용자 상태의 완료 구역도 초기화
            StatusManager.shared.resetDailyStatus()
            // 강제 리렌더 트리거
            self.version = UUID()
        }
    }

    /// 서버에서 오늘 확정 리스트 동기화(GET)
    func syncFromServer(completion: ((Int) -> Void)? = nil) {
        ZoneCheckedService.shared.fetchTodayCheckedZoneIds { [weak self] ids in
            guard let self else { return }
            self.onMainAsync {
                self.state.confirmed = Set(ids)
                self.state.pending.subtract(self.state.confirmed)
                self.persistPendingToStorage()
                self.propagateToStatusManager()
                completion?(ids.count)
            }
        }
    }

    /// 보류 중(pending) 항목을 서버에 재전송 (앱 복귀/네트워크 복구 시 호출 추천)
    func flushPending(completion: (() -> Void)? = nil) {
        let ids = Array(state.pending)
        guard !ids.isEmpty else { completion?(); return }

        let group = DispatchGroup()
        for id in ids {
            group.enter()
            ZoneCheckedService.shared.postChecked(zoneId: id) { [weak self] ok in
                guard let self else { group.leave(); return }
                self.onMainAsync {
                    if ok { self.state.pending.remove(id) }
                    self.persistPendingToStorage()
                    self.propagateToStatusManager()
                    group.leave()
                }
            }
        }
        group.notify(queue: .main) { [weak self] in
            self?.syncFromServer { _ in completion?() }
        }
    }

    // MARK: - Private helpers
    private func effectiveSet() -> Set<Int> {
        state.pending.union(state.confirmed)
    }

    private func propagateToStatusManager() {
        let current = effectiveSet()
        let added = current.subtracting(previousEffective)
        let removed = previousEffective.subtracting(current)

        for id in added { StatusManager.shared.setZoneChecked(zoneId: id, checked: true) }
        for id in removed { StatusManager.shared.setZoneChecked(zoneId: id, checked: false) }

        previousEffective = current
        version = UUID()
    }

    private func loadPendingFromStorage() {
        onMainSync {
            if let arr = UserDefaults.standard.array(forKey: self.pendingKey) as? [Int] {
                self.state.pending = Set(arr)
            }
            let existingChecked = Set(StatusManager.shared.userStatus.zoneCheckedStatus.compactMap { $0.value ? $0.key : nil })
            self.state.confirmed.formUnion(existingChecked)
            self.previousEffective = self.effectiveSet()
        }
    }

    private func persistPendingToStorage() {
        UserDefaults.standard.set(Array(state.pending), forKey: pendingKey)
    }

    // MARK: - Main thread helpers
    private func onMainSync(_ block: () -> Void) {
        if Thread.isMainThread { block() }
        else { DispatchQueue.main.sync { block() } }
    }
    private func onMainAsync(_ block: @escaping () -> Void) {
        if Thread.isMainThread { block() }
        else { DispatchQueue.main.async { block() } }
    }
}


