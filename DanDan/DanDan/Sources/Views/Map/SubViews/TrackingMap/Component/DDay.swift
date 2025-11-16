////
////  DDayView.swift
////  DanDan
////
////  Created by soyeonsoo on 11/3/25.
////
//
//import SwiftUI
//
//struct DDayView: View {
//    @ObservedObject var viewModel: MapScreenViewModel
//    let period: ConquestPeriod
//
//    var body: some View {
//        VStack(spacing: 8) {
//            Text("경기 종료까지")
//                .font(.PR.body4)
//                .foregroundStyle(.gray1)
//
//            Text(viewModel.ddayText)
//                .font(.PR.title2)
//                .foregroundStyle(.steelBlack)
//        }
//        .padding(.vertical, 20)
//        .padding(.horizontal, 22)
//        .background(
//            RoundedRectangle(cornerRadius: 24, style: .continuous)
//                .fill(.ultraThinMaterial)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 24, style: .continuous)
//                        .stroke(.white.opacity(0.6), lineWidth: 1)
//                )
//                .shadow(color: .black.opacity(0.1), radius: 14, x: 0, y: 8)
//        )
//        .fixedSize()
//        .onAppear {
//            viewModel.startDDayTimer(period: period)
//        }
//    }
//}
