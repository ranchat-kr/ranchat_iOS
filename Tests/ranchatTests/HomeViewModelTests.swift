//
//  HomeViewModelTests.swift
//  ranchatTests
//

import Testing
@testable import ranchat

@MainActor
struct HomeViewModelTests {

    @Test func test_checkRoomExist_whenRoomExists_setsIsRoomExistTrue() async {
        let mockRoomRepo = MockRoomRepository()
        mockRoomRepo.mockRoomExist = true

        let viewModel = HomeViewModel(
            userRepository: MockUserRepository(),
            roomRepository: mockRoomRepo
        )

        let idHelper = IdHelper()
        idHelper.setUserId("test-user-id")
        viewModel.idHelper = idHelper

        await viewModel.checkRoomExist()

        #expect(viewModel.isRoomExist == true)
        #expect(viewModel.showNetworkErrorDialog == false)
        #expect(mockRoomRepo.checkRoomExistCallCount == 1)
    }

    @Test func test_checkRoomExist_whenRoomNotExists_setsIsRoomExistFalse() async {
        let mockRoomRepo = MockRoomRepository()
        mockRoomRepo.mockRoomExist = false

        let viewModel = HomeViewModel(
            userRepository: MockUserRepository(),
            roomRepository: mockRoomRepo
        )

        let idHelper = IdHelper()
        idHelper.setUserId("test-user-id")
        viewModel.idHelper = idHelper

        await viewModel.checkRoomExist()

        #expect(viewModel.isRoomExist == false)
    }

    @Test func test_checkRoomExist_whenNetworkError_showsDialog() async {
        let mockRoomRepo = MockRoomRepository()
        mockRoomRepo.shouldThrow = true

        let viewModel = HomeViewModel(
            userRepository: MockUserRepository(),
            roomRepository: mockRoomRepo
        )

        let idHelper = IdHelper()
        idHelper.setUserId("test-user-id")
        viewModel.idHelper = idHelper

        await viewModel.checkRoomExist()

        #expect(viewModel.showNetworkErrorDialog == true)
    }

    @Test func test_checkRoomExist_whenUserIdNil_doesNotCallRepository() async {
        let mockRoomRepo = MockRoomRepository()

        let viewModel = HomeViewModel(
            userRepository: MockUserRepository(),
            roomRepository: mockRoomRepo
        )
        // idHelper not set → getUserId() returns nil

        await viewModel.checkRoomExist()

        #expect(mockRoomRepo.checkRoomExistCallCount == 0)
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
