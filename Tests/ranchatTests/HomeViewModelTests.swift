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

    // MARK: - requestMatching

    func test_requestMatching_whenNetworkUnavailable_showsDialog() {
        let ws = MockWebSocketService()
        let nm = MockNetworkMonitor(isConnected: false)
        let vm = HomeViewModel()
        vm.setup(webSocketService: ws, networkMonitor: nm)

        vm.requestMatching()

        XCTAssertTrue(vm.showNetworkErrorDialog)
        XCTAssertFalse(vm.isMatching)
    }

    func test_requestMatching_whenConnected_setsIsMatching() {
        let ws = MockWebSocketService()
        let nm = MockNetworkMonitor(isConnected: true)
        let vm = HomeViewModel()
        vm.setup(webSocketService: ws, networkMonitor: nm)

        vm.requestMatching()

        XCTAssertTrue(vm.isMatching)
    }

    func test_requestMatching_whenSocketThrows_showsDialog() {
        let ws = MockWebSocketService()
        ws.shouldThrow = true
        let nm = MockNetworkMonitor(isConnected: true)
        let vm = HomeViewModel()
        vm.setup(webSocketService: ws, networkMonitor: nm)

        vm.requestMatching()

        XCTAssertTrue(vm.showNetworkErrorDialog)
        XCTAssertFalse(vm.isMatching)
    }

    // MARK: - successMatching

    func test_successMatching_whenNetworkUnavailable_showsDialog() {
        let ws = MockWebSocketService()
        let nm = MockNetworkMonitor(isConnected: false)
        let vm = HomeViewModel()
        vm.setup(webSocketService: ws, networkMonitor: nm)
        vm.matchedRoomId = "room-1"

        vm.successMatching()

        XCTAssertTrue(vm.showNetworkErrorDialog)
    }

    func test_successMatching_whenMatchedRoomIdEmpty_doesNotNavigate() {
        let ws = MockWebSocketService()
        let nm = MockNetworkMonitor(isConnected: true)
        let vm = HomeViewModel()
        vm.setup(webSocketService: ws, networkMonitor: nm)
        vm.matchedRoomId = ""

        vm.successMatching()

        XCTAssertFalse(vm.goToChat)
    }

    func test_successMatching_whenValid_navigatesToChat() {
        let ws = MockWebSocketService()
        let nm = MockNetworkMonitor(isConnected: true)
        let vm = HomeViewModel()
        vm.setup(webSocketService: ws, networkMonitor: nm)
        vm.matchedRoomId = "room-1"

        vm.successMatching()

        XCTAssertTrue(vm.goToChat)
        XCTAssertFalse(vm.isMatchSuccess)
    }

    // MARK: - setUser

    func test_setUser_whenAlreadyLoading_doesNotCallUseCase() {
        let mockCreate = MockCreateUserUseCase()
        let vm = HomeViewModel(
            createUserUseCase: mockCreate,
            checkRoomExistUseCase: MockCheckRoomExistUseCase(),
            createRoomUseCase: MockCreateRoomUseCase()
        )
        vm.isLoading = true

        vm.setUser()

        XCTAssertEqual(mockCreate.callCount, 0)
    }
}
