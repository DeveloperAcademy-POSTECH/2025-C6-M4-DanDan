//
//  ProfileEditViewModel.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/8/25.
//

import Foundation
import SwiftUI
import UIKit

@MainActor
final class ProfileEditViewModel: ObservableObject {
    private let navigationManager = NavigationManager.shared
    private let myPageService: MyPageServiceProtocol

    // MARK: - Published UI State
    @Published var nickname: String = ""
    @Published var profileImage: UIImage? = nil
    @Published var isNicknameTooLong: Bool = false
    @Published var showDiscardAlert: Bool = false

    // 변경 추적 플래그
    @Published var didRemoveImage: Bool = false
    @Published var didPickNewImage: Bool = false
    @Published var hasServerImage: Bool = false

    // 초기 상태 스냅샷
    private var initialNickname: String = ""
    private var initialProfileImage: UIImage? = nil

    // 제한
    let nicknameMaxLength: Int = 7

    // 버튼 활성화, BackButton 제한
    var isSaveEnabled: Bool {
        let canPut = !nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isNicknameTooLong
        let canDelete = didRemoveImage && hasServerImage
        return canPut || canDelete
    }

    // Alert 활성화
    var hasUnsavedChanges: Bool {
        nickname != initialNickname || didRemoveImage || didPickNewImage
    }
    
    // UI에서 삭제 버튼 노출 제어
    var canDeleteImage: Bool {
        hasServerImage || didPickNewImage
    }

    // MARK: - Init
    init(myPageService: MyPageServiceProtocol = MyPageService()) {
        self.myPageService = myPageService
    }

    // MARK: - Load
    func load() async {
        do {
            let resp = try await myPageService.fetchMyPage()
            // 닉네임 반영
            nickname = resp.data.user.userName

            // 서버 보유 여부는 profileImageKey 기준으로 판별 (기본 URL만 있는 경우는 삭제 불가)
            let serverHasCustomImage = resp.data.user.profileImageKey != nil
            hasServerImage = serverHasCustomImage

            // 프로필 이미지 로드 (URL 존재 시), 없으면 nil 유지 → AvatarEditButton에서 기본 아바타 노출
            if let urlString = resp.data.user.profileUrl, let url = URL(string: urlString) {
                do {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    if let img = UIImage(data: data) {
                        profileImage = img
                    }
                } catch {
                    // 원본 이미지를 못 받아오면 기본 아바타 유지
                    print("⚠️ Profile image load failed:", error)
                    profileImage = nil
                }
            } else { profileImage = nil }

            // 초기 상태 스냅샷 저장 (최초 1회)
            if initialNickname.isEmpty && initialProfileImage == nil {
                initialNickname = nickname
                initialProfileImage = profileImage
            }
            // 닉네임 유효성 초기 계산
            isNicknameTooLong = nickname.count > nicknameMaxLength
        } catch {
            print("🚨 ProfileEdit load failed:", error)
        }
    }

    // MARK: - Save
    /// 수정하기 버튼 액션: 이름만 수정 / 이름+이미지 수정 / 이미지 삭제 분기
    func save() async throws {
        // userId 추출 (JWT sub)
        let token = try TokenManager().getAccessToken()
        guard let userId = AccessTokenDecoder.extractUserId(from: token)?.uuidString else {
            throw NetworkError.unauthorized
        }

        let nameChanged = nickname != initialNickname

        // 2) 새 사진 선택: 이름은 현재 값, 이미지 포함하여 PUT
        if didPickNewImage, let image = profileImage {
            _ = try await MultipartUploadHelper.uploadProfileUpdate(
                userId: userId,
                name: nickname,
                image: image
            )
            navigationManager.pop()
            return
        }

        // 4) 이름 수정 + 사진 삭제: PUT(이름만) → (서버 이미지가 있을 때만) DELETE(이미지)
        if didRemoveImage && nameChanged && profileImage == nil {
            _ = try await MultipartUploadHelper.uploadProfileUpdate(
                userId: userId,
                name: nickname,
                image: nil
            )
            if hasServerImage {
                _ = try await MultipartUploadHelper.deleteProfileImage(userId: userId)
            }
            navigationManager.pop()
            return
        }

        // 3) 사진만 삭제 (서버 이미지가 있을 때만 서버 삭제)
        if didRemoveImage && profileImage == nil && hasServerImage {
            _ = try await MultipartUploadHelper.deleteProfileImage(userId: userId)
            navigationManager.pop()
            return
        }

        // 1) 이름만 수정
        if nameChanged {
            _ = try await MultipartUploadHelper.uploadProfileUpdate(
                userId: userId,
                name: nickname,
                image: nil
            )
            navigationManager.pop()
            return
        }
    }

    // MARK: - Image ops
    func setNewImage(_ image: UIImage) {
        profileImage = image
        didRemoveImage = false
        didPickNewImage = true
    }

    func removeImage() {
        profileImage = nil
        didRemoveImage = true
        didPickNewImage = false
    }

    // MARK: - Validation
    func onNicknameChanged(_ newValue: String) {
        isNicknameTooLong = newValue.count > nicknameMaxLength
    }

    // MARK: - Back handling
    func handleBackTapped() {
        if hasUnsavedChanges {
            showDiscardAlert = true
        } else {
            navigationManager.pop()
        }
    }

    // 초기화(뒤로가기)
    func confirmDiscardAndPop() {
        nickname = initialNickname
        profileImage = initialProfileImage
        didRemoveImage = false
        didPickNewImage = false
        showDiscardAlert = false
        navigationManager.pop()
    }
}
