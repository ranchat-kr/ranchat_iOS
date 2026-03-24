//
//  RoomListViewModelTests.swift
//  ranchatTests
//

import XCTest
@testable import ranchat

@MainActor
final class RoomListViewModelTests: XCTestCase {

    override func setUp() async throws {
        try await super.setUp()
        KeychainHelper.shared.saveUserId("test-user-id")
    }

    override func tearDown() async throws {
        KeychainHelper.shared.deleteUserId()
        try await super.tearDown()
    }

    func test_getRoomList_loadsRooms() async {
        let mockUseCase = MockGetRoomsUseCase()
        mockUseCase.mockRooms = [
            Room(id: 1, title: "Room 1", type: .normal, latestMessage: "안녕하세요", latestMessageAt: Date()),
            Room(id: 2, title: "Room 2", type: .normal, latestMessage: "반가워요", latestMessageAt: Date())
        ]

        let vm = RoomListViewModel(getRoomsUseCase: mockUseCase)

        await vm.getRoomList()

        XCTAssertEqual(vm.roomItems.count, 2)
        XCTAssertTrue(vm.isInitialized)
        XCTAssertFalse(vm.showNetworkErrorDialog)
    }

    func test_getRoomList_whenNetworkError_showsDialog() async {
        let mockUseCase = MockGetRoomsUseCase()
        mockUseCase.shouldThrow = true

        let vm = RoomListViewModel(getRoomsUseCase: mockUseCase)

        await vm.getRoomList()

        XCTAssertTrue(vm.showNetworkErrorDialog)
        XCTAssertTrue(vm.roomItems.isEmpty)
    }

    func test_getRoomList_whenUserIdNil_doesNotLoad() async {
        KeychainHelper.shared.deleteUserId()

        let mockUseCase = MockGetRoomsUseCase()
        mockUseCase.mockRooms = [
            Room(id: 1, title: "Room 1", type: .normal, latestMessage: "Hi", latestMessageAt: Date())
        ]

        let vm = RoomListViewModel(getRoomsUseCase: mockUseCase)

        await vm.getRoomList()

        XCTAssertTrue(vm.roomItems.isEmpty)
        XCTAssertEqual(mockUseCase.callCount, 0)
    }

    func test_getRoomList_isRefresh_clearsAndReloads() async {
        let mockUseCase = MockGetRoomsUseCase()
        mockUseCase.mockRooms = [
            Room(id: 1, title: "Room 1", type: .normal, latestMessage: "Hi", latestMessageAt: Date())
        ]

        let vm = RoomListViewModel(getRoomsUseCase: mockUseCase)
        vm.roomItems = [
            Room(id: 99, title: "Old", type: .normal, latestMessage: "Old", latestMessageAt: Date())
        ]

        await vm.getRoomList(isRefresh: true)

        XCTAssertEqual(vm.roomItems.count, 1)
        XCTAssertEqual(vm.roomItems.first?.id, 1)
    }

    func test_getRoomList_pagination_incrementsPage() async {
        let mockUseCase = MockGetRoomsUseCase()
        mockUseCase.mockRooms = [
            Room(id: 1, title: "Room 1", type: .normal, latestMessage: "Hi", latestMessageAt: Date())
        ]

        let vm = RoomListViewModel(getRoomsUseCase: mockUseCase)

        await vm.getRoomList()
        XCTAssertEqual(vm.roomPage, 1)

        // 두 번째 호출 - 서버에서 같은 totalCount 반환 시 중단
        await vm.getRoomList()
        XCTAssertEqual(mockUseCase.callCount, 2)
    }

    func test_getRoomList_emptyResult_setsInitialized() async {
        let mockUseCase = MockGetRoomsUseCase()
        mockUseCase.mockRooms = []

        let vm = RoomListViewModel(getRoomsUseCase: mockUseCase)

        await vm.getRoomList()

        XCTAssertTrue(vm.roomItems.isEmpty)
        // totalCount(0) == roomItems.count(0) → early return (isInitialized는 set 안 됨)
        XCTAssertFalse(vm.isInitialized)
    }

    // MARK: - isLoading guard

    func test_getRoomList_whenAlreadyLoading_doesNotCallUseCase() async {
        let mockUseCase = MockGetRoomsUseCase()
        let vm = RoomListViewModel(getRoomsUseCase: mockUseCase)
        vm.isLoading = true

        await vm.getRoomList()

        XCTAssertEqual(mockUseCase.callCount, 0)
    }

    // MARK: - enterRoom

    func test_enterRoom_whenNetworkUnavailable_showsDialog() {
        let mockUseCase = MockGetRoomsUseCase()
        let ws = MockWebSocketService()
        let nm = MockNetworkMonitor(isConnected: false)
        let vm = RoomListViewModel(getRoomsUseCase: mockUseCase)
        vm.setup(webSocketService: ws, networkMonitor: nm)
        vm.roomItems = [Room(id: 1, title: "방", type: .normal, latestMessage: "hi", latestMessageAt: Date())]

        vm.enterRoom(at: 0)

        XCTAssertTrue(vm.showNetworkErrorDialog)
        XCTAssertFalse(vm.goToChat)
    }

    func test_enterRoom_whenConnected_navigatesToChat() {
        let mockUseCase = MockGetRoomsUseCase()
        let ws = MockWebSocketService()
        let nm = MockNetworkMonitor(isConnected: true)
        let vm = RoomListViewModel(getRoomsUseCase: mockUseCase)
        vm.setup(webSocketService: ws, networkMonitor: nm)
        vm.roomItems = [Room(id: 1, title: "방", type: .normal, latestMessage: "hi", latestMessageAt: Date())]

        vm.enterRoom(at: 0)

        XCTAssertTrue(vm.goToChat)
        XCTAssertEqual(vm.selectedRoomId, "1")
    }

    func test_enterRoom_whenIndexOutOfBounds_doesNotNavigate() {
        let mockUseCase = MockGetRoomsUseCase()
        let ws = MockWebSocketService()
        let nm = MockNetworkMonitor(isConnected: true)
        let vm = RoomListViewModel(getRoomsUseCase: mockUseCase)
        vm.setup(webSocketService: ws, networkMonitor: nm)
        vm.roomItems = []

        vm.enterRoom(at: 0)

        XCTAssertFalse(vm.goToChat)
    }

    func test_enterRoom_whenSocketThrows_showsDialog() {
        let mockUseCase = MockGetRoomsUseCase()
        let ws = MockWebSocketService()
        ws.shouldThrow = true
        let nm = MockNetworkMonitor(isConnected: true)
        let vm = RoomListViewModel(getRoomsUseCase: mockUseCase)
        vm.setup(webSocketService: ws, networkMonitor: nm)
        vm.roomItems = [Room(id: 1, title: "방", type: .normal, latestMessage: "hi", latestMessageAt: Date())]

        vm.enterRoom(at: 0)

        XCTAssertTrue(vm.showNetworkErrorDialog)
        XCTAssertFalse(vm.goToChat)
    }

    // MARK: - exitRoom

    func test_exitRoom_whenNetworkUnavailable_showsDialog() {
        let mockUseCase = MockGetRoomsUseCase()
        let ws = MockWebSocketService()
        let nm = MockNetworkMonitor(isConnected: false)
        let vm = RoomListViewModel(getRoomsUseCase: mockUseCase)
        vm.setup(webSocketService: ws, networkMonitor: nm)
        vm.roomItems = [Room(id: 1, title: "방", type: .normal, latestMessage: "hi", latestMessageAt: Date())]

        vm.exitRoom(at: 0)

        XCTAssertTrue(vm.showNetworkErrorDialog)
        XCTAssertEqual(vm.roomItems.count, 1)
    }

    func test_exitRoom_whenConnected_removesRoom() {
        let mockUseCase = MockGetRoomsUseCase()
        let ws = MockWebSocketService()
        let nm = MockNetworkMonitor(isConnected: true)
        let vm = RoomListViewModel(getRoomsUseCase: mockUseCase)
        vm.setup(webSocketService: ws, networkMonitor: nm)
        vm.roomItems = [Room(id: 1, title: "방", type: .normal, latestMessage: "hi", latestMessageAt: Date())]

        vm.exitRoom(at: 0)

        XCTAssertTrue(vm.roomItems.isEmpty)
    }

    func test_exitRoom_whenSocketThrows_showsDialog() {
        let mockUseCase = MockGetRoomsUseCase()
        let ws = MockWebSocketService()
        ws.shouldThrow = true
        let nm = MockNetworkMonitor(isConnected: true)
        let vm = RoomListViewModel(getRoomsUseCase: mockUseCase)
        vm.setup(webSocketService: ws, networkMonitor: nm)
        vm.roomItems = [Room(id: 1, title: "방", type: .normal, latestMessage: "hi", latestMessageAt: Date())]

        vm.exitRoom(at: 0)

        XCTAssertTrue(vm.showNetworkErrorDialog)
        XCTAssertEqual(vm.roomItems.count, 1)
    }
}
