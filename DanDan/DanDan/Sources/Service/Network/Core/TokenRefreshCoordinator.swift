//
//  TokenRefreshCoordinator.swift
//  NetworkLayer
//
//  Created on 11/2/25.
//

import Foundation

/// 토큰 갱신을 조율하는 Actor
/// 여러 API 요청이 동시에 401을 받았을 때, 토큰 갱신이 한 번만 실행되도록 보장
actor TokenRefreshCoordinator {
    /// 현재 진행 중인 토큰 갱신 Task
    private var refreshTask: Task<String, Error>?

    /// 토큰 갱신 실행 (이미 진행 중이면 기존 Task의 결과를 기다림)
    /// - Parameter refreshOperation: 실제 토큰 갱신 작업 (클로저)
    /// - Returns: 새로 발급받은 액세스 토큰
    func refresh(using refreshOperation: @escaping () async throws -> String) async throws -> String {
        // 이미 진행 중인 갱신 작업이 있으면 그 결과를 기다림
        if let existingTask = refreshTask {
            return try await existingTask.value
        }

        // 새로운 갱신 작업 시작
        let task = Task {
            try await refreshOperation()
        }

        refreshTask = task

        // 작업 완료 후 정리
        defer {
            refreshTask = nil
        }

        return try await task.value
    }

    /// 진행 중인 갱신 작업 취소
    func cancel() {
        refreshTask?.cancel()
        refreshTask = nil
    }
}
