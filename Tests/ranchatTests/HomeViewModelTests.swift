//
//  HomeViewModelTests.swift
//  ranchatTests
//

import XCTest
@testable import ranchat

@MainActor
final class HomeViewModelTests: XCTestCase {

    override func setUp() async throws {
        try await super.setUp()
        KeychainHelper.shared.saveUserId("test-user-id")
    }

    override func tearDown() async throws {
        KeychainHelper.shared.deleteUserId()
        try await super.tearDown()
    }

    func test_checkRoomExist_whenRoomExists_setsIsRoomExistTrue() async {
        let mockUseCase = MockCheckRoomExistUseCase()
        mockUseCase.mockRoomExist = true

        let viewModel = HomeViewModel(
            createUserUseCase: MockCreateUserUseCase(),
            checkRoomExistUseCase: mockUseCase,
            createRoomUseCase: MockCreateRoomUseCase()
        )

        await viewModel.checkRoomExist()

        XCTAssertTrue(viewModel.isRoomExist)
        XCTAssertFalse(viewModel.showNetworkErrorDialog)
        XCTAssertEqual(mockUseCase.callCount, 1)
    }

    func test_checkRoomExist_whenRoomNotExists_setsIsRoomExistFalse() async {
        let mockUseCase = MockCheckRoomExistUseCase()
        mockUseCase.mockRoomExist = false

        let viewModel = HomeViewModel(
            createUserUseCase: MockCreateUserUseCase(),
            checkRoomExistUseCase: mockUseCase,
            createRoomUseCase: MockCreateRoomUseCase()
        )

        await viewModel.checkRoomExist()

        XCTAssertFalse(viewModel.isRoomExist)
    }

    func test_checkRoomExist_whenNetworkError_showsDialog() async {
        let mockUseCase = MockCheckRoomExistUseCase()
        mockUseCase.shouldThrow = true

        let viewModel = HomeViewModel(
            createUserUseCase: MockCreateUserUseCase(),
            checkRoomExistUseCase: mockUseCase,
            createRoomUseCase: MockCreateRoomUseCase()
        )

        await viewModel.checkRoomExist()

        XCTAssertTrue(viewModel.showNetworkErrorDialog)
    }

    func test_checkRoomExist_whenUserIdNil_doesNotCallUseCase() async {
        KeychainHelper.shared.deleteUserId()

        let mockUseCase = MockCheckRoomExistUseCase()
        let viewModel = HomeViewModel(
            createUserUseCase: MockCreateUserUseCase(),
            checkRoomExistUseCase: mockUseCase,
            createRoomUseCase: MockCreateRoomUseCase()
        )

        await viewModel.checkRoomExist()

        XCTAssertEqual(mockUseCase.callCount, 0)
    }

    func test_getRandomNickname_returnsNonEmpty() {
        let viewModel = HomeViewModel()
        let nickname = viewModel.getRandomNickname()
        XCTAssertFalse(nickname.isEmpty)
    }

    func test_getRandomNickname_hasMinimumLength() {
        let viewModel = HomeViewModel()
        for _ in 0..<10 {
            let nickname = viewModel.getRandomNickname()
            XCTAssertGreaterThanOrEqual(nickname.count, 2)
        }
    }
}
