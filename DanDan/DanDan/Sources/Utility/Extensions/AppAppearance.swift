//
//  AppAppearance.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/2/25.
//

import SwiftUI

import SwiftUI
import UIKit

/// 앱 전체 전역 Appearance 설정을 관리하는 유틸리티
enum AppAppearance {
    static func configure() {
        configureSegmentedControl()
        
        // NavigationBar, TabBar, etc. 추가 가능
    }

    // MARK: SegmentedControl 색상 커스텀
    private static func configureSegmentedControl() {
        let appearance = UISegmentedControl.appearance()
        appearance.selectedSegmentTintColor = UIColor.systemGreen // 선택된 배경
        appearance.backgroundColor = UIColor.systemGray5  // 전체 배경
        appearance.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected) // 선택 텍스트
        appearance.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal) // 비선택 텍스트
    }
}
