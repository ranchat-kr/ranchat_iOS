//
//  ChattingViewModelTests.swift
//  ranchatTests
//

import XCTest
@testable import ranchat

@MainActor
final class ChattingViewModelTests: XCTestCase {

    override func setUp() async throws {
        try await super.setUp()
        KeychainHelper.shared.saveUserId("test-user")
    }

    override func tearDown() async throws {
        KeychainHelper.shared.deleteUserId()
        try await super.tearDown()
    }

    private func makeVM(
        roomId: String = "1",
        getRoomDetailUseCase: any GetRoomDetailUseCase = MockGetRoomDetailUseCase(),
        getMessagesUseCase: any GetMessagesUseCase = MockGetMessagesUseCase(),
        reportUserUseCase: any ReportUserUseCase = MockReportUserUseCase()
    ) -> (ChattingViewModel, MockWebSocketService) {
        let ws = MockWebSocketService()
        let vm = ChattingViewModel(
            roomId: roomId,
            getRoomDetailUseCase: getRoomDetailUseCase,
            getMessagesUseCase: getMessagesUseCase,
            reportUserUseCase: reportUserUseCase
        )
        vm.setup(webSocketService: ws, networkMonitor: MockNetworkMonitor())
        return (vm, ws)
    }

    // MARK: - getRoomDetailData

    func test_getRoomDetailData_success_setsRoomDetail() async {
        let mockUseCase = MockGetRoomDetailUseCase()
        let (vm, _) = makeVM(getRoomDetailUseCase: mockUseCase)

        await vm.getRoomDetailData()

        XCTAssertNotNil(vm.roomDetailData)
        XCTAssertTrue(vm.isRoomDetailDataLoaded)
        XCTAssertFalse(vm.showNetworkErrorDialog)
        XCTAssertEqual(mockUseCase.callCount, 1)
    }

    func test_getRoomDetailData_whenError_showsDialog() async {
        let mockUseCase = MockGetRoomDetailUseCase()
        mockUseCase.shouldThrow = true
        let (vm, _) = makeVM(getRoomDetailUseCase: mockUseCase)

        await vm.getRoomDetailData()

        XCTAssertTrue(vm.showNetworkErrorDialog)
        XCTAssertFalse(vm.isRoomDetailDataLoaded)
    }

    func test_getRoomDetailData_whenUserIdNil_showsDialog() async {
        KeychainHelper.shared.deleteUserId()
        let (vm, _) = makeVM()

        await vm.getRoomDetailData()

        XCTAssertTrue(vm.showNetworkErrorDialog)
    }

    // MARK: - getMessageList

    func test_getMessageList_loadsMessages() async {
        let mockUseCase = MockGetMessagesUseCase()
        mockUseCase.mockMessages = [
            Message(id: 1, roomId: 1, userId: "u1", participantId: 1, participantName: "A",
                    content: "hi", messageType: .chat, contentType: .text, senderType: .user, createdAt: Date())
        ]
        let (vm, _) = makeVM(getMessagesUseCase: mockUseCase)

        await vm.getMessageList()

        XCTAssertEqual(vm.messageDataList.count, 1)
        XCTAssertTrue(vm.isMessageDataListLoaded)
        XCTAssertEqual(mockUseCase.callCount, 1)
    }

    func test_getMessageList_whenError_showsDialog() async {
        let mockUseCase = MockGetMessagesUseCase()
        mockUseCase.shouldThrow = true
        let (vm, _) = makeVM(getMessagesUseCase: mockUseCase)

        await vm.getMessageList()

        XCTAssertTrue(vm.showNetworkErrorDialog)
        XCTAssertTrue(vm.messageDataList.isEmpty)
    }

    // MARK: - sendMessage

    func test_sendMessage_whenEmpty_doesNotSend() {
        let (vm, ws) = makeVM()
        vm.inputText = ""

        vm.sendMessage()

        XCTAssertEqual(ws.sendMessageCallCount, 0)
        XCTAssertFalse(vm.showNetworkErrorDialog)
    }

    func test_sendMessage_success_clearsInput() {
        let (vm, _) = makeVM()
        vm.inputText = "안녕하세요"

        vm.sendMessage()

        XCTAssertEqual(vm.inputText, "")
    }

    func test_sendMessage_whenSocketError_showsDialog() {
        let (vm, ws) = makeVM()
        ws.shouldThrow = true
        vm.inputText = "테스트"

        vm.sendMessage()

        XCTAssertTrue(vm.showNetworkErrorDialog)
    }

    // MARK: - onMessageReceived callback

    func test_onMessageReceived_insertsAtFront() {
        let (vm, ws) = makeVM()
        let existing = Message(id: 1, roomId: 1, userId: "u1", participantId: 1, participantName: "A",
                               content: "old", messageType: .chat, contentType: .text, senderType: .user, createdAt: Date())
        vm.messageDataList = [existing]

        let newMessage = Message(id: 99, roomId: 1, userId: "u1", participantId: 1, participantName: "A",
                                 content: "new", messageType: .chat, contentType: .text, senderType: .user, createdAt: Date())
        ws.onMessageReceivedHandler?(newMessage)

        XCTAssertEqual(vm.messageDataList.first?.id, 99)
        XCTAssertEqual(vm.messageDataList.count, 2)
    }

    // MARK: - shouldDismiss

    func test_exitRoom_setssShouldDismiss() async {
        let (vm, _) = makeVM()

        await vm.exitRoom()

        XCTAssertTrue(vm.shouldDismiss)
    }

    func test_tempExit_setsShouldDismiss() {
        let (vm, _) = makeVM()

        vm.tempExit()

        XCTAssertTrue(vm.shouldDismiss)
    }

    // MARK: - reportUser

    func test_reportUser_callsUseCase() async {
        let mockReport = MockReportUserUseCase()
        let mockDetail = MockGetRoomDetailUseCase()
        mockDetail.mockRoomDetail = RoomDetail(
            id: 1, title: "방", type: .normal,
            participants: [
                Participant(id: 1, userId: "test-user", name: "나"),
                Participant(id: 2, userId: "other-user", name: "상대")
            ]
        )
        let (vm, _) = makeVM(getRoomDetailUseCase: mockDetail, reportUserUseCase: mockReport)
        await vm.getRoomDetailData()

        vm.selectedReason = "스팸"
        await vm.reportUser()

        XCTAssertEqual(mockReport.callCount, 1)
        XCTAssertEqual(mockReport.lastReportType, .spam)
    }

    // MARK: - fetchMessageList

    func test_fetchMessageList_appendsMessages() async {
        let mockUseCase = MockGetMessagesUseCase()
        mockUseCase.mockMessages = [
            Message(id: 10, roomId: 1, userId: "u1", participantId: 1, participantName: "A",
                    content: "fetched", messageType: .chat, contentType: .text, senderType: .user, createdAt: Date())
        ]
        let (vm, _) = makeVM(getMessagesUseCase: mockUseCase)
        await vm.getMessageList()
        let initialCount = vm.messageDataList.count

        vm.totalCount = 999
        await vm.fetchMessageList()

        XCTAssertGreaterThan(vm.messageDataList.count, initialCount)
    }

    func test_fetchMessageList_whenError_rollsBackPage() async {
        let mockUseCase = MockGetMessagesUseCase()
        let (vm, _) = makeVM(getMessagesUseCase: mockUseCase)
        await vm.getMessageList()
        let pageBeforeFetch = vm.currentPage

        mockUseCase.shouldThrow = true
        vm.totalCount = 999
        await vm.fetchMessageList()

        XCTAssertEqual(vm.currentPage, pageBeforeFetch)
        XCTAssertTrue(vm.showNetworkErrorDialog)
    }

    // MARK: - isLoading guard

    func test_getRoomDetailData_whenAlreadyLoading_doesNotCallUseCase() async {
        let mockUseCase = MockGetRoomDetailUseCase()
        let (vm, _) = makeVM(getRoomDetailUseCase: mockUseCase)
        vm.isLoading = true

        await vm.getRoomDetailData()

        XCTAssertEqual(mockUseCase.callCount, 0)
    }

    func test_reportUser_whenAlreadyLoading_doesNotCallUseCase() async {
        let mockReport = MockReportUserUseCase()
        let (vm, _) = makeVM(reportUserUseCase: mockReport)
        vm.isLoading = true

        await vm.reportUser()

        XCTAssertEqual(mockReport.callCount, 0)
    }

    // MARK: - sendMessage network check

    func test_sendMessage_whenNetworkUnavailable_showsDialog() {
        let (vm, _) = makeVM()
        vm.networkMonitor = MockNetworkMonitor(isConnected: false)
        vm.inputText = "안녕"

        vm.sendMessage()

        XCTAssertTrue(vm.showNetworkErrorDialog)
        XCTAssertEqual(vm.inputText, "안녕")
    }
}
