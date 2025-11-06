# Multipart/Form-Data 업로드 가이드

프로필 이미지를 포함한 게스트 회원가입 시 `multipart/form-data` 형식으로 데이터를 전송하는 방법을 안내합니다.

---

## 📋 백엔드 API 요구사항

### POST /auth/guest/register
- **Content-Type**: `multipart/form-data`
- **필드**:
  - `name` (필수, string): 사용자 이름
  - `file` (선택, binary): 프로필 이미지 (최대 5MB)

### 응답
```json
{
  "user": {
    "id": 1,
    "name": "산책러",
    "profileUrl": "https://storage.example.com/profiles/abc123.jpg",
    "isGuest": true,
    "profileImageKey": "profiles/abc123.jpg"
  },
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

---

## 🔧 구현 방법

### 방법 1: URLSession으로 직접 구현 (추천)

```swift
func uploadGuestRegister(
    name: String,
    image: UIImage?
) async throws -> GuestRegisterResponse {
    // 1. URL 생성
    guard let url = URL(string: NetworkConfig.baseURL + "/auth/guest/register") else {
        throw NetworkError.invalidRequest
    }

    // 2. URLRequest 생성
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.timeoutInterval = 30

    // 3. Boundary 생성
    let boundary = "Boundary-\(UUID().uuidString)"
    request.setValue(
        "multipart/form-data; boundary=\(boundary)",
        forHTTPHeaderField: "Content-Type"
    )

    // 4. Body 데이터 생성
    var body = Data()

    // name 필드 추가
    body.append("--\(boundary)\r\n".data(using: .utf8)!)
    body.append("Content-Disposition: form-data; name=\"name\"\r\n\r\n".data(using: .utf8)!)
    body.append("\(name)\r\n".data(using: .utf8)!)

    // 이미지 파일 추가 (있는 경우)
    if let image = image, let imageData = image.jpegData(compressionQuality: 0.8) {
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"profile.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
    }

    // 종료 바운더리
    body.append("--\(boundary)--\r\n".data(using: .utf8)!)

    request.httpBody = body

    // 5. 요청 전송
    let (data, response) = try await URLSession.shared.data(for: request)

    // 6. 응답 검증
    guard let httpResponse = response as? HTTPURLResponse else {
        throw NetworkError.invalidResponse
    }

    guard (200...299).contains(httpResponse.statusCode) else {
        throw NetworkError.httpError(statusCode: httpResponse.statusCode, data: data)
    }

    // 7. 응답 디코딩
    let decoder = JSONDecoder()
    return try decoder.decode(GuestRegisterResponse.self, from: data)
}
```

### 사용 예시

```swift
class GuestRegisterViewModel: ObservableObject {
    @Published var userName = ""
    @Published var selectedImage: UIImage?
    @Published var isLoading = false

    private let tokenManager: TokenManagerProtocol

    init(tokenManager: TokenManagerProtocol = TokenManager()) {
        self.tokenManager = tokenManager
    }

    func register() {
        isLoading = true

        Task {
            do {
                let response = try await uploadGuestRegister(
                    name: userName,
                    image: selectedImage
                )

                // 토큰 저장
                try tokenManager.saveTokens(
                    accessToken: response.accessToken,
                    refreshToken: response.refreshToken
                )

                await MainActor.run {
                    print("✅ 등록 성공!")
                    print("Profile URL: \(response.user.profileUrl ?? "없음")")
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    print("❌ 등록 실패: \(error)")
                    isLoading = false
                }
            }
        }
    }
}
```

---

## 🎯 방법 2: Alamofire 사용 (선택)

Alamofire를 사용하면 더 간단하게 구현할 수 있습니다.

### 1. Alamofire 설치

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.8.0")
]
```

### 2. 구현

```swift
import Alamofire

func uploadGuestRegisterWithAlamofire(
    name: String,
    image: UIImage?
) async throws -> GuestRegisterResponse {
    let url = NetworkConfig.baseURL + "/auth/guest/register"

    return try await withCheckedThrowingContinuation { continuation in
        AF.upload(
            multipartFormData: { multipartFormData in
                // name 필드
                multipartFormData.append(
                    name.data(using: .utf8)!,
                    withName: "name"
                )

                // 이미지 파일
                if let image = image,
                   let imageData = image.jpegData(compressionQuality: 0.8) {
                    multipartFormData.append(
                        imageData,
                        withName: "file",
                        fileName: "profile.jpg",
                        mimeType: "image/jpeg"
                    )
                }
            },
            to: url,
            method: .post
        )
        .validate()
        .responseDecodable(of: GuestRegisterResponse.self) { response in
            switch response.result {
            case .success(let registerResponse):
                continuation.resume(returning: registerResponse)
            case .failure(let error):
                continuation.resume(throwing: error)
            }
        }
    }
}
```

---

## 📱 SwiftUI 이미지 선택 예시

```swift
import SwiftUI
import PhotosUI

struct GuestRegisterView: View {
    @StateObject private var viewModel = GuestRegisterViewModel()
    @State private var selectedItem: PhotosPickerItem?

    var body: some View {
        VStack(spacing: 20) {
            // 프로필 이미지 선택
            PhotosPicker(
                selection: $selectedItem,
                matching: .images
            ) {
                if let image = viewModel.selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 100, height: 100)
                        .overlay(
                            Image(systemName: "camera.fill")
                                .foregroundColor(.gray)
                        )
                }
            }
            .onChange(of: selectedItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        viewModel.selectedImage = image
                    }
                }
            }

            // 이름 입력
            TextField("이름을 입력하세요", text: $viewModel.userName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            // 등록 버튼
            Button(action: {
                viewModel.register()
            }) {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    Text("시작하기")
                }
            }
            .disabled(viewModel.userName.isEmpty || viewModel.isLoading)
        }
        .padding()
    }
}
```

---

## ⚠️ 주의사항

### 1. 파일 크기 제한
- 백엔드에서 최대 5MB로 제한하고 있음
- 업로드 전에 이미지 크기를 확인하거나 압축 필요

```swift
// 이미지 크기 확인
if let imageData = image.jpegData(compressionQuality: 0.8) {
    let sizeInMB = Double(imageData.count) / 1_000_000
    if sizeInMB > 5 {
        throw NetworkError.invalidRequest  // "파일이 너무 큽니다"
    }
}
```

### 2. 압축 품질 조정
```swift
// 고품질 (용량 큼)
image.jpegData(compressionQuality: 1.0)

// 중간 품질 (추천)
image.jpegData(compressionQuality: 0.8)

// 저품질 (용량 작음)
image.jpegData(compressionQuality: 0.5)
```

### 3. 타임아웃 설정
- 이미지 업로드는 시간이 걸릴 수 있으므로 타임아웃을 길게 설정
```swift
request.timeoutInterval = 30  // 30초
```

### 4. 에러 처리
```swift
do {
    let response = try await uploadGuestRegister(name: name, image: image)
    // 성공
} catch let error as NetworkError {
    switch error {
    case .httpError(let statusCode, _):
        if statusCode == 413 {
            print("파일이 너무 큽니다")
        }
    default:
        print("네트워크 오류: \(error.localizedDescription)")
    }
} catch {
    print("알 수 없는 오류: \(error)")
}
```

---

## 🧪 테스트

### 이미지 없이 테스트
```swift
let response = try await uploadGuestRegister(name: "산책러", image: nil)
// profileUrl은 nil이어야 함
```

### 이미지 포함 테스트
```swift
let image = UIImage(named: "test_profile")
let response = try await uploadGuestRegister(name: "산책러", image: image)
// profileUrl이 반환되어야 함
```

---

## 📚 참고 자료

- [Apple Developer - URLSession](https://developer.apple.com/documentation/foundation/urlsession)
- [Alamofire Documentation](https://github.com/Alamofire/Alamofire)
- [RFC 7578 - Multipart/Form-Data](https://tools.ietf.org/html/rfc7578)

---

## 💡 요약

1. **이름만 전송**: `GuestAuthService.registerGuest(name:)` 사용 (JSON)
2. **이미지 포함 전송**: 위 가이드의 `uploadGuestRegister(name:image:)` 사용 (multipart/form-data)
3. **토큰은 자동 저장**: 응답에서 받은 accessToken, refreshToken을 TokenManager에 저장
4. **이미지 선택**: SwiftUI의 `PhotosPicker` 또는 UIKit의 `UIImagePickerController` 사용
