//
//  BackButton.swift
//  DanDan
//
//  Created by soyeonsoo on 11/6/25.
//

/*
 사용 방법
 
 // 26.0 이전 버전인 경우 true인 변수
 private var needsCustomBackButton : Bool {
     if #available(iOS 26.0, *) { return false } else { return true }
 }
 
 .toolbar {
     if needsCustomBackButton
     {
         ToolbarItem(placement: .topBarLeading) {
             BackButton { dismiss() }
         }
     }
 }
 
 */

import SwiftUI

struct BackButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.steelBlack)
                .padding(8)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
