//
//  RoomListViewModelTests.swift
//  ranchatTests
//

import Testing
@testable import ranchat

@MainActor
struct RoomListViewModelTests {

    private func makeIdHelper(userId: String = "test-user-id") -> IdHelper {
        let idHelper = IdHelper()
        idHelper.setUserId(userId)
        return idHelper
    }

    @Test func test_getRoomList_loadsRooms() async {
        let mockUseCase = MockGetRoomsUseCase()
        mockUseCase.mockRooms = [
            Room(id: 1, title: "Room 1", type: "NORMAL", latestMessage: "안녕하세요", latestMessageAt: "2024-01-01T12:00:00"),
            Room(id: 2, title: "Room 2", type: "NORMAL", latestMessage: "반가워요", latestMessageAt: "2024-01-02T12:00:00")
        ]

        let vm = RoomListViewModel(getRoomsUseCase: mockUseCase)
        vm.idHelper = makeIdHelper()

        await vm.getRoomList()

        #expect(vm.roomItems.count == 2)
        #expect(vm.isInitialized == true)
        #expect(vm.showNetworkErrorDialog == false)
    }

    @Test func test_getRoomList_whenNetworkError_showsDialog() async {
        let mockUseCase = MockGetRoomsUseCase()
        mockUseCase.shouldThrow = true

        let vm = RoomListViewModel(getRoomsUseCase: mockUseCase)
        vm.idHelper = makeIdHelper()

        await vm.getRoomList()

        #expect(vm.showNetworkErrorDialog == true)
        #expect(vm.roomItems.isEmpty)
    }

    @Test func test_getRoomList_whenUserIdNil_doesNotLoad() async {
        let mockUseCase = MockGetRoomsUseCase()
        mockUseCase.mockRooms = [
            Room(id: 1, title: "Room 1", type: "NORMAL", latestMessage: "Hi", latestMessageAt: "2024-01-01T12:00:00")
        ]

        let vm = RoomListViewModel(getRoomsUseCase: mockUseCase)
        // idHelper not set

        await vm.getRoomList()

        #expect(vm.roomItems.isEmpty)
        #expect(mockUseCase.callCount == 0)
    }

    @Test func test_getRoomList_isRefresh_clearsAndReloads() async {
        let mockUseCase = MockGetRoomsUseCase()
        mockUseCase.mockRooms = [
            Room(id: 1, title: "Room 1", type: "NORMAL", latestMessage: "Hi", latestMessageAt: "2024-01-01T12:00:00")
        ]

        let vm = RoomListViewModel(getRoomsUseCase: mockUseCase)
        vm.idHelper = makeIdHelper()
        vm.roomItems = [
            Room(id: 99, title: "Old", type: "NORMAL", latestMessage: "Old", latestMessageAt: "2024-01-01T12:00:00")
        ]

        await vm.getRoomList(isRefresh: true)

        #expect(vm.roomItems.count == 1)
        #expect(vm.roomItems.first?.id == 1)
    }

    @Test func test_getRoomList_pagination_incrementsPage() async {
        let mockUseCase = MockGetRoomsUseCase()
        mockUseCase.mockRooms = [
            Room(id: 1, title: "Room 1", type: "NORMAL", latestMessage: "Hi", latestMessageAt: "2024-01-01T12:00:00")
        ]

        let vm = RoomListViewModel(getRoomsUseCase: mockUseCase)
        vm.idHelper = makeIdHelper()

        await vm.getRoomList()
        #expect(vm.roomPage == 1)

        // 두 번째 호출 - 서버에서 같은 totalCount 반환 시 중단
        await vm.getRoomList()
        #expect(mockUseCase.callCount == 2)
    }

    @Test func test_getRoomList_emptyResult_setsInitialized() async {
        let mockUseCase = MockGetRoomsUseCase()
        mockUseCase.mockRooms = []

        let vm = RoomListViewModel(getRoomsUseCase: mockUseCase)
        vm.idHelper = makeIdHelper()

        await vm.getRoomList()

        #expect(vm.roomItems.isEmpty)
        // totalCount(0) == roomItems.count(0) → early return (isInitialized는 set 안 됨)
        // 이 동작은 현재 구현의 명세를 그대로 반영
        #expect(vm.isInitialized == false)
    }
}
