//
//  HomeViewModelTests.swift
//  ranchatTests
//

import Testing
@testable import ranchat

@MainActor
struct HomeViewModelTests {

    @Test func test_checkRoomExist_whenRoomExists_setsIsRoomExistTrue() async {
        let mockUseCase = MockCheckRoomExistUseCase()
        mockUseCase.mockRoomExist = true

        let viewModel = HomeViewModel(
            createUserUseCase: MockCreateUserUseCase(),
            checkRoomExistUseCase: mockUseCase,
            createRoomUseCase: MockCreateRoomUseCase()
        )

        let idHelper = IdHelper()
        idHelper.setUserId("test-user-id")
        viewModel.idHelper = idHelper

        await viewModel.checkRoomExist()

        #expect(viewModel.isRoomExist == true)
        #expect(viewModel.showNetworkErrorDialog == false)
        #expect(mockUseCase.callCount == 1)
    }

    @Test func test_checkRoomExist_whenRoomNotExists_setsIsRoomExistFalse() async {
        let mockUseCase = MockCheckRoomExistUseCase()
        mockUseCase.mockRoomExist = false

        let viewModel = HomeViewModel(
            createUserUseCase: MockCreateUserUseCase(),
            checkRoomExistUseCase: mockUseCase,
            createRoomUseCase: MockCreateRoomUseCase()
        )

        let idHelper = IdHelper()
        idHelper.setUserId("test-user-id")
        viewModel.idHelper = idHelper

        await viewModel.checkRoomExist()

        #expect(viewModel.isRoomExist == false)
    }

    @Test func test_checkRoomExist_whenNetworkError_showsDialog() async {
        let mockUseCase = MockCheckRoomExistUseCase()
        mockUseCase.shouldThrow = true

        let viewModel = HomeViewModel(
            createUserUseCase: MockCreateUserUseCase(),
            checkRoomExistUseCase: mockUseCase,
            createRoomUseCase: MockCreateRoomUseCase()
        )

        let idHelper = IdHelper()
        idHelper.setUserId("test-user-id")
        viewModel.idHelper = idHelper

        await viewModel.checkRoomExist()

        #expect(viewModel.showNetworkErrorDialog == true)
    }

    @Test func test_checkRoomExist_whenUserIdNil_doesNotCallUseCase() async {
        let mockUseCase = MockCheckRoomExistUseCase()

        let viewModel = HomeViewModel(
            createUserUseCase: MockCreateUserUseCase(),
            checkRoomExistUseCase: mockUseCase,
            createRoomUseCase: MockCreateRoomUseCase()
        )
        // idHelper not set → getUserId() returns nil

        await viewModel.checkRoomExist()

        #expect(mockUseCase.callCount == 0)
    }

    @Test func test_getRandomNickname_returnsNonEmpty() {
        let viewModel = HomeViewModel()
        let nickname = viewModel.getRandomNickname()
        #expect(!nickname.isEmpty)
    }

    @Test func test_getRandomNickname_hasMinimumLength() {
        let viewModel = HomeViewModel()
        for _ in 0..<10 {
            let nickname = viewModel.getRandomNickname()
            #expect(nickname.count >= 2)
        }
    }
}
