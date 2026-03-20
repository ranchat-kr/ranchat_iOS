# 랜톡 (Ran-Talk)

익명 랜덤 채팅 iOS 앱

## 앱 소개

랜톡은 실시간 랜덤 매칭을 통해 낯선 사람과 익명으로 대화할 수 있는 채팅 앱입니다. 매칭 대기 중에는 WebSocket으로 자동 매칭되며, 8초 내 매칭이 안 될 경우 AI(GPT)와 대화할 수 있는 방이 자동 생성됩니다.

## 🟢 주요 기능

- **랜덤 매칭** — START 버튼 클릭 시 다른 사용자와 랜덤 매칭, 8초 내 상대 없으면 AI와 매칭
- **채팅 관리** — 기존 매칭된 채팅방 재입장, 신고 및 방 나가기, 닉네임 변경
- **푸시 알림** — Firebase Cloud Messaging 기반 메시지 수신 알림

## ⚙️ 기술 스택

| 분류 | 기술 |
|---|---|
| 언어 | Swift 5.9 |
| UI 프레임워크 | SwiftUI |
| 아키텍처 | MVVM + Repository Pattern |
| 상태 관리 | @Observable (Swift Observation) |
| 네트워크 | Alamofire, WebSocket (STOMP) |
| 보안 | Keychain Services |
| 푸시 알림 | Firebase Cloud Messaging |
| 테스트 | Swift Testing (`@Test`, `#expect`) |
| 의존성 관리 | CocoaPods, Swift Package Manager |

## 🏗️ 아키텍처

```
View
 └─ ViewModel (@Observable)
      └─ Repository (Protocol)
           └─ DefaultRepository (Alamofire 네트워크 구현)
```

**Repository Pattern 도입 이유**

기존에는 ViewModel이 `ApiHelper.shared` 싱글턴을 직접 호출해 테스트가 불가능한 구조였습니다. Repository 프로토콜을 도입해 의존성을 역전시켜 Mock 객체로 교체 가능한 구조로 개선했습니다.

```swift
// ViewModel init - 프로덕션은 DefaultRepository, 테스트는 MockRepository
init(
    userRepository: UserRepository = DefaultUserRepository(),
    roomRepository: RoomRepository = DefaultRoomRepository()
) { ... }
```

**보안 개선**

`@AppStorage` (UserDefaults)로 평문 저장하던 userId를 iOS Keychain으로 마이그레이션했습니다.

```swift
KeychainHelper.shared.saveUserId(uuid)
KeychainHelper.shared.getUserId()
```

## 📁 프로젝트 구조

```
ranchat/
├── Util/
│   ├── KeychainHelper.swift       # Keychain userId 관리
│   └── ...
├── Repository/
│   ├── UserRepository.swift       # 프로토콜
│   ├── RoomRepository.swift
│   ├── ChatRepository.swift
│   ├── NotificationRepository.swift
│   ├── DefaultUserRepository.swift  # 실제 구현
│   └── ...
├── Home/ │ RoomList/ │ Chatting/ └── Setting/

Tests/ranchatTests/
├── Mock/
│   ├── MockUserRepository.swift
│   ├── MockRoomRepository.swift
│   └── MockChatRepository.swift
├── HomeViewModelTests.swift
├── SettingViewModelTests.swift
└── RoomListViewModelTests.swift
```

## 📱 UI/UX 특징

- 단순하고 직관적인 인터페이스, START 버튼 중심으로 빠른 접근
- AI 매칭 기능으로 대기 시간 최소화
- Pull-to-Refresh로 채팅방 목록 갱신

## 🚀 실행 방법

```bash
# 의존성 설치
pod install

# Xcode에서 열기
open ranchat.xcworkspace
```

> ⚠️ `GoogleService-Info.plist` 및 Firebase 설정은 별도 제공이 필요합니다.
