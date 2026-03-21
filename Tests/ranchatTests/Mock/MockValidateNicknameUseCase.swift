//
//  MockValidateNicknameUseCase.swift
//  ranchatTests
//

@testable import ranchat

class MockValidateNicknameUseCase: ValidateNicknameUseCase {
    var mockError: NicknameError = .none
    var callCount = 0

    func execute(nickname: String, currentName: String?) -> NicknameError {
        callCount += 1
        return mockError
    }
}
