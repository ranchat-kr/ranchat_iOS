# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# 의존성 설치 (최초 1회 또는 Podfile 변경 시)
pod install

# Xcode 워크스페이스 열기 (반드시 .xcworkspace 사용)
open ranchat.xcworkspace

# 테스트 실행 (CLI)
xcodebuild test \
  -workspace ranchat.xcworkspace \
  -scheme ranchat \
  -destination 'platform=iOS Simulator,name=iPhone 16'

# 단일 테스트 실행 (테스트 클래스명/함수명 지정)
xcodebuild test \
  -workspace ranchat.xcworkspace \
  -scheme ranchat \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:ranchatTests/ChattingViewModelTests/test_sendMessage_success_clearsInput
```

> `GoogleService-Info.plist`가 없으면 빌드가 실패합니다. Firebase 설정 파일은 별도 제공이 필요합니다.

## 아키텍처

Clean Architecture 4계층. 의존성은 **단방향**으로만 허용됩니다.

```
Presentation → Domain ← Data
                ↑
         Infrastructure
```

| 계층 | 위치 | 의존 가능 | 의존 불가 |
|---|---|---|---|
| Domain | `ranchat/Domain/` | Foundation만 | Data, Infra, Presentation |
| Data | `ranchat/Data/` | Domain, Alamofire | Infra, Presentation |
| Infrastructure | `ranchat/Infrastructure/` | Domain Service 프로토콜 | Presentation |
| Presentation | `ranchat/Presentation/` | Domain(UseCase/Entity) | Data 직접 참조 |

### UseCase 패턴

각 UseCase 파일에 `protocol`과 `Default` 구현체가 함께 정의됩니다.

```swift
// Domain/UseCase/User/GetUserUseCase.swift
protocol GetUserUseCase {
    func execute(userId: String) async throws -> User
}
final class DefaultGetUserUseCase: GetUserUseCase { ... }
```

ViewModel은 init 기본값으로 `Default` 구현체를 받고, 테스트 시 Mock을 주입합니다.

```swift
init(getUserUseCase: any GetUserUseCase = DefaultGetUserUseCase()) { ... }
```

### DTO → Domain 변환

Data 계층의 DTO는 `toDomain()` 메서드로 Domain Entity로 변환됩니다. Repository는 DTO를 반환하지 않고 항상 Domain Entity를 반환합니다.

### WebSocket 콜백 패턴

`WebSocketHelper`(Infrastructure)는 `ChattingViewModel`(Presentation)을 직접 참조하지 않습니다. ViewModel이 `setup(webSocketService:idHelper:networkMonitor:)` 호출 시 핸들러를 등록합니다.

```swift
webSocketService.setOnMessageReceived { [weak self] message in
    self?.messageDataList.insert(message, at: 0)
}
```

### 앱 수준 DI

`RanchatApp`에서 세 개의 공유 인스턴스를 생성해 `@Environment`로 전달합니다.

```swift
// ranchatApp.swift
private var webSocketHelper = WebSocketHelper()
private var idHelper = IdHelper()
private var networkMonitor = NetworkMonitor()
```

각 View는 `.environment()`로 받고, ViewModel은 `view.onAppear`에서 `setup(webSocketService:idHelper:networkMonitor:)`을 통해 주입받습니다.

## 주요 규칙 및 패턴

**에러 타입**:
- `ApiHelperError` (`Data/NetworkError.swift`) — `invalidURLError`, `networkError(String)`, `responseDataError`, `nilError`. Repository/UseCase에서 사용.
- `WebSocketHelperError` (`Infrastructure/WebSocket/WebSocketHelper.swift`) — `invalidURLError`, `networkError(String)`, `responseDataError`, `connectError`, `nilError`.
- `WebSocketServiceError` (`Domain/Service/WebSocketService.swift`) — `notConnected`, `nilParameter`.
- `IdHelperError` (`Infrastructure/Session/IdHelper.swift`) — `invalidUserIdError`, `invalidRoomIdError`, `nilUserIdError`, `nilRoomIdError`, `nilError`.

**API 응답 구조**: `ApiResponseDTO<T>` — 필드: `status`, `message`, `serverDateTime`, `data: T?`. `Status.success.rawValue`와 비교 후 `data`를 언래핑합니다 (`status == "SUCCESS"` 문자열 직접 비교 금지).

**NetworkClient**: Data 계층은 Alamofire를 직접 호출하지 않고 `NetworkClient` 프로토콜(`Data/DataSource/NetworkClient.swift`)을 통해 요청합니다. 구현체는 `AlamofireNetworkClient`.

**userId 흐름**: `KeychainHelper.shared.getUserId()` → `IdHelper.setUserId()` → WebSocket 메서드 파라미터로 전달. `SettingViewModel` 등 일부 ViewModel은 `IdHelper` 없이 `KeychainHelper.shared`를 직접 참조합니다. `@AppStorage` 사용 금지 (보안 이슈로 Keychain으로 마이그레이션 완료).

**싱글톤**: `KeychainHelper.shared`, `DefaultData.shared`, `Logger.shared` — Infrastructure가 주 사용처이나, Presentation 계층(ViewModel, View)에서도 직접 사용됩니다.

**알림 전역 이벤트**: FCM 탭 → `NotificationCenter.default.post(name: .pushNotificationReceived)` → View에서 `.onReceive`로 수신.

**로깅**: `Logger.shared.log(className, #function, message, .error?)`.

## 필수 워크플로우 (예외 없이 따른다)

### 새 기능·화면 추가 요청

아래 순서를 반드시 지킨다.

**1단계 — 설계 (코드 작성 전)**
- 관련 파일을 읽어 기존 패턴 파악
- 만들 파일 목록, 각 파일의 계층·역할, 인터페이스 시그니처를 먼저 명시
- 계층 의존성 규칙 위반 여부 확인 후 진행

**2단계 — 구현**
- Domain: `import Foundation`만. 프로토콜 + Default 구현체를 같은 파일에 정의
- ViewModel: `@MainActor @Observable class`. init 기본값으로 Default UseCase 주입
- `isLoading = true` 앞에 반드시 `guard !isLoading else { return }` 추가 (새로 작성하는 메서드 기준)
- `isLoading = false`는 do-catch 블록 밖(Task 클로저 최하단)에 위치하는 것이 이상적 (기존 코드 일부는 분기별 배치)
- Repository 직접 참조 금지 — UseCase를 통해야 함

**3단계 — 테스트**
- 구현 완료 후 자동으로 테스트 파일 작성
- `Tests/ranchatTests/[Name]ViewModelTests.swift` 생성
- `Tests/ranchatTests/Mock/Mock[Name]UseCase.swift` 생성
- 각 public 메서드에 성공·에러·엣지 케이스 3가지 커버

### 코드 수정 요청

- 수정 전 반드시 해당 파일 읽기
- 수정 후 계층 규칙 위반 여부 재확인
- 영향받는 테스트가 있으면 함께 업데이트

### 커밋 요청

- 형식: `[type] 한국어 설명` (type: feat/fix/refactor/chore/docs/test)
- `Co-Authored-By` 절대 포함 금지
- 관련 파일만 선택적으로 `git add`

## 테스트 구조

- 프레임워크: XCTest (`XCTestCase`, `XCTAssert*`, `@MainActor final class`)
- 위치: `Tests/ranchatTests/`
- Mock: `Tests/ranchatTests/Mock/` — UseCase, Repository, WebSocketService Mock 포함
- ViewModel 테스트는 `makeVM()` 헬퍼 함수로 Mock UseCase를 조합해 생성합니다.
