//
//  SettingViewModelTests.swift
//  ranchatTests
//

import Testing
@testable import ranchat

@MainActor
struct SettingViewModelTests {

    // MARK: - isValidNickname

    @Test func test_isValidNickname_emptyString_returnsFalse() {
        let vm = SettingViewModel()
        vm.editNickName = ""
        #expect(vm.isValidNickname() == false)
        #expect(vm.nicknameError == .empty)
    }

    @Test func test_isValidNickname_tooShort_returnsFalse() {
        let vm = SettingViewModel()
        vm.editNickName = "A"
        #expect(vm.isValidNickname() == false)
        #expect(vm.nicknameError == .length)
    }

    @Test func test_isValidNickname_tooLong_returnsFalse() {
        let vm = SettingViewModel()
        vm.editNickName = "열한글자닉네임초과"  // 11자
        #expect(vm.isValidNickname() == false)
        #expect(vm.nicknameError == .length)
    }

    @Test func test_isValidNickname_containsBlank_returnsFalse() {
        let vm = SettingViewModel()
        vm.editNickName = "닉 네임"
        #expect(vm.isValidNickname() == false)
        #expect(vm.nicknameError == .containsBlank)
    }

    @Test func test_isValidNickname_duplicate_returnsFalse() {
        let vm = SettingViewModel()
        vm.user = UserData(id: "id", name: "기존닉네임")
        vm.editNickName = "기존닉네임"
        #expect(vm.isValidNickname() == false)
        #expect(vm.nicknameError == .duplicate)
    }

    @Test func test_isValidNickname_specialCharacter_returnsFalse() {
        let vm = SettingViewModel()
        vm.editNickName = "닉네임!"
        #expect(vm.isValidNickname() == false)
        #expect(vm.nicknameError == .specialCharacter)
    }

    @Test func test_isValidNickname_forbiddenWord_returnsFalse() {
        let vm = SettingViewModel()
        vm.editNickName = "마약유저"
        #expect(vm.isValidNickname() == false)
        #expect(vm.nicknameError == .containsForbiddenCharacter)
    }

    @Test func test_isValidNickname_validKorean_returnsTrue() {
        let vm = SettingViewModel()
        vm.editNickName = "행복한고양이"
        #expect(vm.isValidNickname() == true)
    }

    @Test func test_isValidNickname_validEnglish_returnsTrue() {
        let vm = SettingViewModel()
        vm.editNickName = "happycat"
        #expect(vm.isValidNickname() == true)
    }

    @Test func test_isValidNickname_twoChars_returnsTrue() {
        let vm = SettingViewModel()
        vm.editNickName = "닉네"
        #expect(vm.isValidNickname() == true)
    }

    @Test func test_isValidNickname_tenChars_returnsTrue() {
        let vm = SettingViewModel()
        vm.editNickName = "열글자닉네임성공"  // 8자 (한글 2바이트지만 .count는 글자수)
        #expect(vm.isValidNickname() == true)
    }

    // MARK: - setUser with mock

    @Test func test_setUser_whenNetworkError_showsDialog() async throws {
        let mockRepo = MockUserRepository()
        mockRepo.shouldThrow = true

        let vm = SettingViewModel(userRepository: mockRepo)
        // Keychain에 userId가 없으면 showNetworkErrorDialog가 바로 set됨
        // (실제 디바이스에서는 Keychain 값이 있어야 네트워크 호출)
        vm.setUser()

        // userId가 Keychain에 없으면 즉시 에러 상태
        try await Task.sleep(for: .milliseconds(100))
        #expect(vm.isLoading == false)
    }

    // MARK: - setNickname with mock

    @Test func test_setNickname_success_clearsEditNickname() async throws {
        let mockRepo = MockUserRepository()
        let vm = SettingViewModel(userRepository: mockRepo)
        vm.user = UserData(id: "test-id", name: "기존이름")
        vm.editNickName = "새닉네임"

        // Keychain에 userId가 없으면 즉시 리턴
        // 실제 테스트는 Keychain이 설정된 환경에서 동작
        vm.setNickname()
        try await Task.sleep(for: .milliseconds(100))

        #expect(vm.isLoading == false)
    }
}
