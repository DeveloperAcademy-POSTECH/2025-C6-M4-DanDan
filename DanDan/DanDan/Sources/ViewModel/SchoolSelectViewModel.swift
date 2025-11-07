//
//  LoginViewModel.swift
//  DanDan
//
//  Created by Jay on 11/7/25.
//

import Foundation
import UIKit

@MainActor
class SchoolSelectViewModel: ObservableObject {
    private let authService = GuestAuthService()

    @Published var userName: String = ""
    @Published var teamName: String = ""
    @Published var profileImage: UIImage?
    @Published var message: String = ""

    func registerGuest() async {
        do {
            let response = try await authService.registerGuest(
                teamName: teamName,
                userName: userName,
                profileImage: profileImage
            )

            let data = response.data
            message = "✅ \(data.user.name)이(가) \(teamName) 팀으로 등록되었습니다!"
            print("Access Token:", data.accessToken)
        } catch {
            message = "❌ 게스트 등록 실패: \(error.localizedDescription)"
        }
    }
}
