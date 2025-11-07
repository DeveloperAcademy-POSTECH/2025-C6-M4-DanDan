//
//  WaitingView.swift
//  DanDan
//
//  Created by soyeonsoo on 11/7/25.
//

import SwiftUI
import Combine

// 오로지 UT용 화면
// 11월 14일 16시에 TeamAssignmentView로 이동
struct WaitingView: View {
    private let navigationManager = NavigationManager.shared
    
    @State private var hasReached = false
    @State private var cancellable: AnyCancellable?
    
    private let targetDate: Date = {
        var date = DateComponents()
        date.year = 2025
        date.month = 11
        date.day = 14
        date.hour = 16
        date.minute = 0
        return Calendar.current.date(from: date)!
    }()
    
    var body: some View {
        ZStack {
            Image("bg_waiting")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea(edges: .all)
                .offset(y: 100)
            
            TitleSectionView(title: "11월 14일 16시에 게임이 시작돼요", description: "몸을 풀며 기다려주세요!")
                .padding(.top, 50)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .onAppear {
            startTimer()
        }
        .onChange(of: hasReached) { _, newValue in
            if newValue {
                navigateToMapScreen()
            }
        }
    }
    
    private func startTimer() {
        // 테스트용: 3초 뒤 자동 전환
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            hasReached = true
        }
        
        // TODO: 배포 전에 이걸 살리기
//        cancellable = Timer.publish(every: 1, on: .main, in: .common)
//            .autoconnect()
//            .sink { _ in
//                if hasReachedTargetDate(target: targetDate) {
//                    hasReached = true
//                    cancellable?.cancel()
//                }
//            }
    }
    
    private func hasReachedTargetDate(target: Date) -> Bool {
        return Date() >= target
    }
    
    private func navigateToMapScreen() {
        navigationManager.navigate(to: .main)
    }
}
