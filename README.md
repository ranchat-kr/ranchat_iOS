# 랜톡 (Ran-Talk)

> 랜덤 매칭 기반 익명 실시간 채팅 iOS 앱

![Swift](https://img.shields.io/badge/Swift-5.0-orange) ![iOS](https://img.shields.io/badge/iOS-17.4+-blue) ![Xcode](https://img.shields.io/badge/Xcode-16.0+-lightgrey)

[![Play Store](https://img.shields.io/badge/Play_Store-Download-414141?logo=google-play&logoColor=white)](https://play.google.com/store/apps/details?id=com.kihyeonkim.rantalk)

<br>

## 스크린샷

| 홈 | 채팅방 목록 | 채팅 |
|:---:|:---:|:---:|
| <img src="Assets/screenshots/home.png" width="200"> | <img src="Assets/screenshots/chatting_rooms.png" width="200"> | <img src="Assets/screenshots/chatting.png" width="200"> |

| 신고 | 푸시 알림 딥링크 |
|:---:|:---:|
| <img src="Assets/screenshots/report.png" width="200"> | <img src="Assets/screenshots/pushNotification_to_ChattingRoom.gif" width="200"> |

<br>

## 주요 기능

| 기능 | 설명 |
|------|------|
| 랜덤 매칭 | START 버튼으로 랜덤 사용자와 즉시 매칭 |
| AI 매칭 | 8초 내 상대가 없으면 GPT와 대화하는 방 자동 생성 |
| 실시간 채팅 | WebSocket STOMP 기반 메시지 송수신, 발신 시간 표시, 무한 스크롤 |
| 채팅방 목록 | 기존 매칭된 방 재입장, Pull-to-Refresh |
| 사용자 신고 | 채팅 상대방 신고 (스팸·욕설·광고·허위정보·저작권 침해·기타) |
| 설정 | 닉네임 변경, 푸시 알림 ON/OFF |
| 푸시 알림 | FCM 기반 메시지 수신 알림, 탭 시 해당 채팅방으로 딥링크 이동 |
| 보안 | iOS Keychain Services를 이용한 userId 암호화 저장 |

<br>

## 기술 스택

| 분류 | 사용 기술 |
|------|----------|
| 언어 | Swift |
| UI | SwiftUI |
| 아키텍처 | Clean Architecture (MVVM + UseCase + Repository) |
| 상태 관리 | @Observable (Swift Observation) |
| 비동기 | async/await, @MainActor |
| 네트워크 | Alamofire |
| WebSocket | StompClientLib (STOMP 프로토콜) |
| 보안 | iOS Keychain Services |
| 푸시 알림 | Firebase Cloud Messaging (FCM) |
| 테스트 | XCTest |
| 의존성 관리 | CocoaPods, Swift Package Manager |

<br>

## 아키텍처

```mermaid
%%{init: {'theme': 'neutral'}}%%
graph TB
    classDef pres  fill:#bfdbfe,stroke:#3b82f6,color:#1e3a5f
    classDef dom   fill:#bbf7d0,stroke:#16a34a,color:#14532d
    classDef dat   fill:#fed7aa,stroke:#ea580c,color:#7c2d12
    classDef infra fill:#e9d5ff,stroke:#7c3aed,color:#3b0764

    subgraph Presentation["📱 Presentation Layer"]
        View["Views (SwiftUI)\n(HomeView · RoomListView\nChattingView · SettingView)"]
        VM["ViewModels (@Observable)\n(HomeVM · RoomListVM\nChattingVM · SettingVM)"]
        View --> VM
    end

    subgraph Domain["🏛️ Domain Layer (순수 Swift)"]
        UseCase["UseCases\n(User · Room · Chat · Notification)"]
        RepoProto["Repository Protocols\n(UserRepository · RoomRepository\nChatRepository · NotificationRepository)"]
        ServiceProto["WebSocketService Protocol"]
        Entity["Entities\n(User · Room · Message · RoomDetail\nReportType · NicknameError 등)"]
        UseCase --> RepoProto
        UseCase --> Entity
    end

    subgraph Data["🗄️ Data Layer"]
        Repo["Repositories\n(DefaultUserRepository\nDefaultRoomRepository 등)"]
        DTO["DTOs (+toDomain())\n(UserDTO · RoomDTO · MessageDTO 등)"]
        Network["NetworkClient\n(AlamofireNetworkClient)"]
        Repo --> DTO
        Repo --> Network
    end

    subgraph Infrastructure["⚙️ Infrastructure Layer"]
        WS["WebSocketHelper\n(STOMP, StompClientLib)"]
        Keychain["KeychainHelper"]
        NM["NetworkMonitor"]
        Logger["Logger"]
        WS -->|"implements"| ServiceProto
    end

    VM -->|"UseCase Protocol 호출"| UseCase
    Repo -->|"Protocol 구현"| RepoProto
    VM -->|"setup(webSocketService:networkMonitor:)"| WS

    class View,VM pres
    class UseCase,RepoProto,ServiceProto,Entity dom
    class Repo,DTO,Network dat
    class WS,Keychain,NM,Logger infra
```

<br>

## 프로젝트 구조

```
ranchat/
├── ranchatApp.swift
├── ContentView.swift
├── Domain/
│   ├── Entity/
│   ├── Repository/           # Repository Protocols
│   ├── Service/              # WebSocketService Protocol
│   └── UseCase/
│       ├── User/
│       ├── Room/
│       ├── Chat/
│       └── Notification/
├── Data/
│   ├── DTO/
│   ├── DataSource/           # NetworkClient
│   ├── LocalStorage/
│   └── Repository/
├── Infrastructure/
│   ├── WebSocket/            # WebSocketHelper (STOMP)
│   ├── Keychain/
│   ├── Network/
│   ├── Session/
│   └── Logger/
└── Presentation/
    ├── Home/
    ├── RoomList/
    ├── Chatting/
    ├── Setting/
    ├── Common/
    └── Extension/
```
