//
//  ValidateNicknameUseCaseTests.swift
//  ranchatTests
//

import XCTest
@testable import ranchat

final class ValidateNicknameUseCaseTests: XCTestCase {

    private let useCase = DefaultValidateNicknameUseCase()

    // MARK: - 빈 값

    func test_empty_returnsEmpty() {
        XCTAssertEqual(useCase.execute(nickname: "", currentName: nil), .empty)
    }

    // MARK: - 길이

    func test_oneChar_returnsLength() {
        XCTAssertEqual(useCase.execute(nickname: "A", currentName: nil), .length)
    }

    func test_elevenChars_returnsLength() {
        XCTAssertEqual(useCase.execute(nickname: "열한글자닉네임초과다더", currentName: nil), .length)
    }

    func test_twoChars_returnsNone() {
        XCTAssertEqual(useCase.execute(nickname: "닉네", currentName: nil), .none)
    }

    func test_tenChars_returnsNone() {
        XCTAssertEqual(useCase.execute(nickname: "열글자닉네임테스트OK", currentName: nil), .none)
    }

    // MARK: - 공백

    func test_containsSpace_returnsContainsBlank() {
        XCTAssertEqual(useCase.execute(nickname: "닉 네임", currentName: nil), .containsBlank)
    }

    func test_containsTab_returnsContainsBlank() {
        XCTAssertEqual(useCase.execute(nickname: "닉\t네임", currentName: nil), .containsBlank)
    }

    // MARK: - 중복

    func test_sameAsCurrent_returnsDuplicate() {
        XCTAssertEqual(useCase.execute(nickname: "기존닉네임", currentName: "기존닉네임"), .duplicate)
    }

    func test_differentFromCurrent_returnsNone() {
        XCTAssertEqual(useCase.execute(nickname: "새닉네임", currentName: "기존닉네임"), .none)
    }

    func test_nilCurrent_doesNotReturnDuplicate() {
        XCTAssertEqual(useCase.execute(nickname: "새닉네임", currentName: nil), .none)
    }

    // MARK: - 특수문자

    func test_exclamationMark_returnsSpecialCharacter() {
        XCTAssertEqual(useCase.execute(nickname: "닉네임!", currentName: nil), .specialCharacter)
    }

    func test_atSign_returnsSpecialCharacter() {
        XCTAssertEqual(useCase.execute(nickname: "닉네@임", currentName: nil), .specialCharacter)
    }

    func test_koreanOnly_returnsNone() {
        XCTAssertEqual(useCase.execute(nickname: "행복한고양이", currentName: nil), .none)
    }

    func test_englishOnly_returnsNone() {
        XCTAssertEqual(useCase.execute(nickname: "happycat", currentName: nil), .none)
    }

    func test_alphanumericMixed_returnsNone() {
        XCTAssertEqual(useCase.execute(nickname: "user123", currentName: nil), .none)
    }

    // MARK: - 금지 단어

    func test_forbiddenWord_returnsContainsForbiddenCharacter() {
        XCTAssertEqual(useCase.execute(nickname: "마약유저", currentName: nil), .containsForbiddenCharacter)
    }

    func test_forbiddenWordEmbedded_returnsContainsForbiddenCharacter() {
        XCTAssertEqual(useCase.execute(nickname: "씨발놈아", currentName: nil), .containsForbiddenCharacter)
    }

    func test_normalWord_returnsNone() {
        XCTAssertEqual(useCase.execute(nickname: "즐거운바다", currentName: nil), .none)
    }
}
