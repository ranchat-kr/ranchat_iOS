//
//  ValidateNicknameUseCaseTests.swift
//  ranchatTests
//

import Testing
@testable import ranchat

struct ValidateNicknameUseCaseTests {

    private let useCase = DefaultValidateNicknameUseCase()

    // MARK: - 빈 값

    @Test func test_empty_returnsEmpty() {
        #expect(useCase.execute(nickname: "", currentName: nil) == .empty)
    }

    // MARK: - 길이

    @Test func test_oneChar_returnsLength() {
        #expect(useCase.execute(nickname: "A", currentName: nil) == .length)
    }

    @Test func test_elevenChars_returnsLength() {
        #expect(useCase.execute(nickname: "열한글자닉네임초과다더", currentName: nil) == .length)
    }

    @Test func test_twoChars_returnsNone() {
        #expect(useCase.execute(nickname: "닉네", currentName: nil) == .none)
    }

    @Test func test_tenChars_returnsNone() {
        #expect(useCase.execute(nickname: "열글자닉네임테스트OK", currentName: nil) == .none)
    }

    // MARK: - 공백

    @Test func test_containsSpace_returnsContainsBlank() {
        #expect(useCase.execute(nickname: "닉 네임", currentName: nil) == .containsBlank)
    }

    @Test func test_containsTab_returnsContainsBlank() {
        #expect(useCase.execute(nickname: "닉\t네임", currentName: nil) == .containsBlank)
    }

    // MARK: - 중복

    @Test func test_sameAsCurrent_returnsDuplicate() {
        #expect(useCase.execute(nickname: "기존닉네임", currentName: "기존닉네임") == .duplicate)
    }

    @Test func test_differentFromCurrent_returnsNone() {
        #expect(useCase.execute(nickname: "새닉네임", currentName: "기존닉네임") == .none)
    }

    @Test func test_nilCurrent_doesNotReturnDuplicate() {
        #expect(useCase.execute(nickname: "새닉네임", currentName: nil) == .none)
    }

    // MARK: - 특수문자

    @Test func test_exclamationMark_returnsSpecialCharacter() {
        #expect(useCase.execute(nickname: "닉네임!", currentName: nil) == .specialCharacter)
    }

    @Test func test_atSign_returnsSpecialCharacter() {
        #expect(useCase.execute(nickname: "닉네@임", currentName: nil) == .specialCharacter)
    }

    @Test func test_koreanOnly_returnsNone() {
        #expect(useCase.execute(nickname: "행복한고양이", currentName: nil) == .none)
    }

    @Test func test_englishOnly_returnsNone() {
        #expect(useCase.execute(nickname: "happycat", currentName: nil) == .none)
    }

    @Test func test_alphanumericMixed_returnsNone() {
        #expect(useCase.execute(nickname: "user123", currentName: nil) == .none)
    }

    // MARK: - 금지 단어

    @Test func test_forbiddenWord_returnsContainsForbiddenCharacter() {
        #expect(useCase.execute(nickname: "마약유저", currentName: nil) == .containsForbiddenCharacter)
    }

    @Test func test_forbiddenWordEmbedded_returnsContainsForbiddenCharacter() {
        #expect(useCase.execute(nickname: "씨발놈아", currentName: nil) == .containsForbiddenCharacter)
    }

    @Test func test_normalWord_returnsNone() {
        #expect(useCase.execute(nickname: "즐거운바다", currentName: nil) == .none)
    }
}
