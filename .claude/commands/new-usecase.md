새 UseCase를 Clean Architecture 패턴에 맞게 생성합니다.

## 입력 형식
`/new-usecase [Layer/Name]`

예: `/new-usecase Room/DeleteRoom` → `DeleteRoomUseCase`

## 생성할 파일

### 1. `ranchat/Domain/UseCase/[Layer]/[Name]UseCase.swift`
```swift
import Foundation

protocol [Name]UseCase {
    func execute(...) async throws -> ...
}

final class Default[Name]UseCase: [Name]UseCase {
    private let [repository]: [Repository]   // bare protocol — `any` 사용 금지

    init([repository]: [Repository] = Default[Repository]()) {
        self.[repository] = [repository]
    }

    func execute(...) async throws -> ... {
        try await [repository].[method](...)
    }
}
```

### 2. `Tests/ranchatTests/Mock/Mock[Name]UseCase.swift`
```swift
@testable import ranchat

class Mock[Name]UseCase: [Name]UseCase {
    var shouldThrow = false
    var callCount = 0
    // 반환값이 있으면 mockResult 프로퍼티 추가

    func execute(...) async throws -> ... {
        callCount += 1
        if shouldThrow { throw ApiHelperError.networkError("mock error") }
        // return mockResult
    }
}
```

## 주의사항
- Domain 계층: `import Foundation`만 허용
- 에러 타입은 `ApiHelperError` 사용
- 프로토콜과 Default 구현체를 같은 파일에 정의
- Xcode project.pbxproj에 파일 참조 추가는 별도 작업 필요

## 요청
$ARGUMENTS
