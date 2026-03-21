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
| 아키텍처 | Clean Architecture (MVVM + UseCase + Repository) |
| 상태 관리 | @Observable (Swift Observation) |
| 네트워크 | Alamofire, WebSocket (STOMP) |
| 보안 | Keychain Services |
| 푸시 알림 | Firebase Cloud Messaging |
| 테스트 | Swift Testing (`@Test`, `#expect`) |
| 의존성 관리 | CocoaPods, Swift Package Manager |

## 🏗️ 아키텍처

```
View (SwiftUI)
 └─ ViewModel (@Observable, @MainActor)
      └─ UseCase (Domain 비즈니스 로직)
           └─ Repository Protocol (Domain 인터페이스)
                └─ DefaultRepository (Data — Alamofire 구현)
```

### 레이어별 역할

| 레이어 | 역할 | 의존 가능 |
|---|---|---|
| Domain | Entity, Repository 프로토콜, UseCase | Foundation만 |
| Data | DTO, NetworkClient, Repository 구현체 | Domain, Alamofire |
| Infrastructure | WebSocket, Keychain, NetworkMonitor | Domain(Service 프로토콜) |
| Presentation | ViewModel, View | Domain(UseCase/Entity) |

**Clean Architecture 도입 이유**

기존 구조에서는 두 가지 핵심 문제가 있었습니다.

1. **Infrastructure → Presentation 직접 참조**: `WebSocketHelper`가 `ChattingViewModel`을 직접 들고 있어 의존성 방향이 역전되었습니다. `WebSocketService` 프로토콜과 callback 패턴으로 해소했습니다.

```swift
// Before (위반)
class WebSocketHelper {
    weak var chattingViewModel: ChattingViewModel?
}

// After (callback 역전)
protocol WebSocketService {
    func setOnMessageReceived(_ handler: @escaping @MainActor (Message) -> Void)
}
```

2. **ViewModel → Repository 직접 호출**: 비즈니스 로직이 ViewModel에 흩어져 테스트가 어려웠습니다. UseCase 계층을 도입해 로직을 분리하고 ViewModel은 UseCase만 호출합니다.

```swift
// ViewModel init — 프로덕션은 Default, 테스트는 Mock
init(
    checkRoomExistUseCase: any CheckRoomExistUseCase = DefaultCheckRoomExistUseCase(),
    createRoomUseCase: any CreateRoomUseCase = DefaultCreateRoomUseCase()
) { ... }
```

**보안**

`@AppStorage` (UserDefaults 평문)로 저장하던 userId를 iOS Keychain으로 마이그레이션했습니다.

```swift
KeychainHelper.shared.saveUserId(uuid)
KeychainHelper.shared.getUserId()
```

## 📁 프로젝트 구조

```
ranchat/
├── Domain/
│   ├── Entity/          # 순수 Swift 모델 (User, Room, Message, ...)
│   ├── Repository/      # Repository 프로토콜
│   ├── Service/         # WebSocketService 프로토콜
│   └── UseCase/         # User/ Room/ Chat/ Notification/
├── Data/
│   ├── DTO/             # Codable API 응답 + toDomain()
│   ├── DataSource/      # NetworkClient 프로토콜 + Alamofire 구현
│   └── Repository/      # Default*Repository (DTO→Domain 변환)
├── Infrastructure/
│   ├── WebSocket/       # WebSocketHelper (WebSocketService 구현)
│   ├── Keychain/        # KeychainHelper
│   ├── Network/         # NetworkMonitor, DefaultData
│   └── Session/         # IdHelper
└── Presentation/
    ├── Home/ RoomList/ Chatting/ Setting/
    └── Common/ Extension/

Tests/ranchatTests/
├── Mock/
│   ├── MockCheckRoomExistUseCase.swift
│   ├── MockCreateRoomUseCase.swift
│   ├── MockCreateUserUseCase.swift
│   ├── MockGetRoomsUseCase.swift
│   ├── MockGetUserUseCase.swift
│   ├── MockUpdateUserNameUseCase.swift
│   └── MockValidateNicknameUseCase.swift
├── HomeViewModelTests.swift
├── RoomListViewModelTests.swift
├── SettingViewModelTests.swift
└── ValidateNicknameUseCaseTests.swift
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
