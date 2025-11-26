//
//  ProfileSetupViewModel.swift
//  DanDan
//
//  Created by Jay on 11/10/25.
//

import Foundation
import UIKit

@MainActor
class ProfileSetupViewModel: ObservableObject {
    @Published var nickname: String = ""
    @Published var profileImage: UIImage? = UIImage(named: "default_avatar")

    private let navigationManager = NavigationManager.shared

    /// 프로필 설정 화면으로 이동합니다.
    func tapTeamInputButton() {
        navigationManager.navigate(
            to: .teamInput(
                nickname: nickname,
                image: profileImage
            )
        )
    }
}
