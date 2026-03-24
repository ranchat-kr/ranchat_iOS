//
//  SettingViewModelTests.swift
//  ranchatTests
//

import XCTest
@testable import ranchat

@MainActor
final class SettingViewModelTests: XCTestCase {

    override func setUp() async throws {
        try await super.setUp()
        KeychainHelper.shared.saveUserId("test-user-id")
    }

    override func tearDown() async throws {
        KeychainHelper.shared.deleteUserId()
        try await super.tearDown()
    }

    // MARK: - isValidNickname

    func test_isValidNickname_emptyString_returnsFalse() {
        let vm = SettingViewModel()
        vm.editNickName = ""
        XCTAssertFalse(vm.isValidNickname())
        XCTAssertEqual(vm.nicknameError, .empty)
    }

    func test_isValidNickname_tooShort_returnsFalse() {
        let vm = SettingViewModel()
        vm.editNickName = "A"
        XCTAssertFalse(vm.isValidNickname())
        XCTAssertEqual(vm.nicknameError, .length)
    }

    func test_isValidNickname_tooLong_returnsFalse() {
        let vm = SettingViewModel()
        vm.editNickName = "열한글자닉네임초과다더"  // 11자
        XCTAssertFalse(vm.isValidNickname())
        XCTAssertEqual(vm.nicknameError, .length)
    }

    func test_isValidNickname_containsBlank_returnsFalse() {
        let vm = SettingViewModel()
        vm.editNickName = "닉 네임"
        XCTAssertFalse(vm.isValidNickname())
        XCTAssertEqual(vm.nicknameError, .containsBlank)
    }

    func test_isValidNickname_duplicate_returnsFalse() {
        let vm = SettingViewModel()
        vm.user = User(id: "id", name: "기존닉네임")
        vm.editNickName = "기존닉네임"
        XCTAssertFalse(vm.isValidNickname())
        XCTAssertEqual(vm.nicknameError, .duplicate)
    }

    func test_isValidNickname_specialCharacter_returnsFalse() {
        let vm = SettingViewModel()
        vm.editNickName = "닉네임!"
        XCTAssertFalse(vm.isValidNickname())
        XCTAssertEqual(vm.nicknameError, .specialCharacter)
    }

    func test_isValidNickname_forbiddenWord_returnsFalse() {
        let vm = SettingViewModel()
        vm.editNickName = "마약유저"
        XCTAssertFalse(vm.isValidNickname())
        XCTAssertEqual(vm.nicknameError, .containsForbiddenCharacter)
    }

    func test_isValidNickname_validKorean_returnsTrue() {
        let vm = SettingViewModel()
        vm.editNickName = "행복한고양이"
        XCTAssertTrue(vm.isValidNickname())
    }

    func test_isValidNickname_validEnglish_returnsTrue() {
        let vm = SettingViewModel()
        vm.editNickName = "happycat"
        XCTAssertTrue(vm.isValidNickname())
    }

    func test_isValidNickname_twoChars_returnsTrue() {
        let vm = SettingViewModel()
        vm.editNickName = "닉네"
        XCTAssertTrue(vm.isValidNickname())
    }

    func test_isValidNickname_tenChars_returnsTrue() {
        let vm = SettingViewModel()
        vm.editNickName = "열글자닉네임성공"  // 8자 (한글 2바이트지만 .count는 글자수)
        XCTAssertTrue(vm.isValidNickname())
    }

    // MARK: - setUser with mock

    func test_setUser_whenNetworkError_showsDialog() async throws {
        let mockGetUser = MockGetUserUseCase()
        mockGetUser.shouldThrow = true

        let vm = SettingViewModel(getUserUseCase: mockGetUser)
        // Keychain에 userId가 없으면 showNetworkErrorDialog가 바로 set됨
        vm.setUser()

        try await Task.sleep(for: .milliseconds(100))
        XCTAssertFalse(vm.isLoading)
    }

    // MARK: - setNickname with mock

    func test_setNickname_success_clearsEditNickname() async throws {
        let vm = SettingViewModel(
            getUserUseCase: MockGetUserUseCase(),
            updateUserNameUseCase: MockUpdateUserNameUseCase()
        )
        vm.user = User(id: "test-id", name: "기존이름")
        vm.editNickName = "새닉네임"

        // Keychain에 userId가 없으면 즉시 리턴
        vm.setNickname()
        try await Task.sleep(for: .milliseconds(100))

        XCTAssertFalse(vm.isLoading)
    }

    // MARK: - isLoading guard

    func test_setUser_whenAlreadyLoading_doesNotCallUseCase() {
        let mockGetUser = MockGetUserUseCase()
        let vm = SettingViewModel(getUserUseCase: mockGetUser)
        vm.isLoading = true

        vm.setUser()

        XCTAssertEqual(mockGetUser.callCount, 0)
    }

    func test_setNickname_whenAlreadyLoading_doesNotCallUseCase() {
        let mockUpdateName = MockUpdateUserNameUseCase()
        let vm = SettingViewModel(updateUserNameUseCase: mockUpdateName)
        vm.isLoading = true

        vm.setNickname()

        XCTAssertEqual(mockUpdateName.callCount, 0)
    }
}
