//
//  OfflineZoneCompletionQueue.swift
//  DanDan
//
//  Created by Assistant on 11/11/25.
//

import Foundation

final class OfflineZoneCompletionQueue {
    static let shared = OfflineZoneCompletionQueue()
    
    private let storageKey = "offline_zone_completion_queue"
    private var queue: [Int] = []
    private var isProcessing = false
    
    private init() {
        load()
    }
    
    func enqueue(zoneId: Int) {
        if !queue.contains(zoneId) {
            queue.append(zoneId)
            save()
        }
    }
    
    func processQueueIfPossible() {
        guard !isProcessing, !queue.isEmpty else { return }
        isProcessing = true
        processNext()
    }
    
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
    
    private func save() {
        UserDefaults.standard.set(queue, forKey: storageKey)
    }
    
    private func load() {
        if let arr = UserDefaults.standard.array(forKey: storageKey) as? [Int] {
            self.queue = arr
        }
    }
}


