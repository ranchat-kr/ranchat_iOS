새 화면(View + ViewModel)을 프로젝트 패턴에 맞게 생성합니다.

## 입력 형식
`/new-screen [ScreenName]`

예: `/new-screen Profile`

## 생성할 파일

### 1. `ranchat/Presentation/[ScreenName]/[ScreenName]View.swift`
```swift
import SwiftUI

struct [ScreenName]View: View {
    @Environment(WebSocketHelper.self) private var webSocketHelper
    @Environment(IdHelper.self) private var idHelper
    @Environment(NetworkMonitor.self) private var networkMonitor

    @State private var viewModel = [ScreenName]ViewModel()

    var body: some View {
        // ...
        .onAppear {
            viewModel.setup(
                webSocketService: webSocketHelper,
                idHelper: idHelper,
                networkMonitor: networkMonitor
            )
        }
    }
}
```

### 2. `ranchat/Presentation/[ScreenName]/[ScreenName]ViewModel.swift`
```swift
import Foundation

@MainActor
@Observable
class [ScreenName]ViewModel {
    let className = "[ScreenName]ViewModel"

    var isLoading = false
    var showNetworkErrorDialog = false
    var networkErrorTitle = "오류"
    var networkErrorContent = "알 수 없는 오류가 발생했습니다."

    var webSocketService: (any WebSocketService)?
    var idHelper: IdHelper?
    var networkMonitor: NetworkMonitor?

    private var someUseCase: any SomeUseCase

    init(someUseCase: any SomeUseCase = DefaultSomeUseCase()) {
        self.someUseCase = someUseCase
    }

    func setup(webSocketService: any WebSocketService, idHelper: IdHelper, networkMonitor: NetworkMonitor) {
        self.webSocketService = webSocketService
        self.idHelper = idHelper
        self.networkMonitor = networkMonitor
    }
}
```

## 주의사항
- ViewModel은 `@MainActor @Observable class`
- UseCase init 기본값으로 `Default` 구현체 지정 (테스트 교체 가능)
- WebSocket이 필요 없는 화면은 setup() 생략 가능
- `isLoading = true` 전에 `guard !isLoading else { return }` 추가

## 화면 이름
$ARGUMENTS
