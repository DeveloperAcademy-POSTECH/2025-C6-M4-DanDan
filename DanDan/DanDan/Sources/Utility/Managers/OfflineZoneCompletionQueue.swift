//
//  OfflineZoneCompletionQueue.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/11/25.
//

import Foundation

/// 오프라인 상태에서 완료된 구역(zoneId)을 임시 저장하고,
/// 네트워크가 복구되면 서버로 재전송하는 큐를 관리합니다.
final class OfflineZoneCompletionQueue {
    static let shared = OfflineZoneCompletionQueue()
    
    private let storageKey = "offline_zone_completion_queue"
    private var queue: [Int] = []
    private var isProcessing = false
    
    private init() {
        load()
    }
    
    /// 새로운 구역 ID를 큐에 추가합니다.
    /// - Parameter zoneId: 완료된 구역의 ID
    func enqueue(zoneId: Int) {
        if !queue.contains(zoneId) {
            queue.append(zoneId)
            save()
        }
    }
    
    /// 현재 큐를 처리할 수 있는 상태인지 확인하고,
    /// 가능하면 큐의 다음 아이템 처리를 시작합니다.
    func processQueueIfPossible() {
        guard !isProcessing, !queue.isEmpty else { return }
        isProcessing = true
        processNext()
    }
    
    /// 큐의 첫 번째 구역 ID를 서버에 전송하고,
    /// 성공 시 큐에서 제거 후 다음 아이템 처리를 진행합니다.
    /// 실패 시 처리를 중단하고 다음 기회에 재시도합니다.
    private func processNext() {
        guard !queue.isEmpty else {
            isProcessing = false
            save()
            return
        }
        let zoneId = queue.first!
        
        ZoneCheckedService.shared.postChecked(zoneId: zoneId) { ok in
            guard ok else {
                // 실패 → 다음 기회에 재시도
                self.isProcessing = false
                return
            }
            ZoneCheckedService.shared.acquireScore(zoneId: zoneId) { ok2 in
                if ok2 {
                    // 성공 → 큐에서 제거하고 다음 진행
                    if !self.queue.isEmpty && self.queue.first == zoneId {
                        self.queue.removeFirst()
                        self.save()
                    }
                    self.processNext()
                } else {
                    // 실패 → 다음 기회에 재시도
                    self.isProcessing = false
                }
            }
        }
    }
    
    /// 현재 큐를 UserDefaults에 저장합니다.
    private func save() {
        UserDefaults.standard.set(queue, forKey: storageKey)
    }
    
    /// UserDefaults에서 큐를 불러옵니다.
    private func load() {
        if let arr = UserDefaults.standard.array(forKey: storageKey) as? [Int] {
            self.queue = arr
        }
    }
    
    /// 로그아웃 등 세션 종료 시 큐를 비웁니다.
    func reset() {
        queue.removeAll()
        save()
    }
}
