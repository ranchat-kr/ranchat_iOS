//
//  ChattingViewModelTests.swift
//  ranchatTests
//

import Testing
@testable import ranchat

@MainActor
struct ChattingViewModelTests {

    private func makeIdHelper(userId: String = "test-user", roomId: String = "1") -> IdHelper {
        let helper = IdHelper()
        helper.setUserId(userId)
        helper.setRoomId(roomId)
        return helper
    }

    private func makeVM(
        getRoomDetailUseCase: any GetRoomDetailUseCase = MockGetRoomDetailUseCase(),
        getMessagesUseCase: any GetMessagesUseCase = MockGetMessagesUseCase(),
        reportUserUseCase: any ReportUserUseCase = MockReportUserUseCase()
    ) -> (ChattingViewModel, MockWebSocketService) {
        let ws = MockWebSocketService()
        let vm = ChattingViewModel(
            getRoomDetailUseCase: getRoomDetailUseCase,
            getMessagesUseCase: getMessagesUseCase,
            reportUserUseCase: reportUserUseCase
        )
        vm.setup(webSocketService: ws, idHelper: makeIdHelper(), networkMonitor: NetworkMonitor())
        return (vm, ws)
    }

    // MARK: - getRoomDetailData

    @Test func test_getRoomDetailData_success_setsRoomDetail() async {
        let mockUseCase = MockGetRoomDetailUseCase()
        let (vm, _) = makeVM(getRoomDetailUseCase: mockUseCase)

        await vm.getRoomDetailData()

        #expect(vm.roomDetailData != nil)
        #expect(vm.isRoomDetailDataLoaded == true)
        #expect(vm.showNetworkErrorDialog == false)
        #expect(mockUseCase.callCount == 1)
    }

    @Test func test_getRoomDetailData_whenError_showsDialog() async {
        let mockUseCase = MockGetRoomDetailUseCase()
        mockUseCase.shouldThrow = true
        let (vm, _) = makeVM(getRoomDetailUseCase: mockUseCase)

        await vm.getRoomDetailData()

        #expect(vm.showNetworkErrorDialog == true)
        #expect(vm.isRoomDetailDataLoaded == false)
    }

    @Test func test_getRoomDetailData_whenIdHelperNil_showsDialog() async {
        let vm = ChattingViewModel()
        // idHelper not set

        await vm.getRoomDetailData()

        #expect(vm.showNetworkErrorDialog == true)
    }

    // MARK: - getMessageList

    @Test func test_getMessageList_loadsMessages() async {
        let mockUseCase = MockGetMessagesUseCase()
        mockUseCase.mockMessages = [
            Message(id: 1, roomId: 1, userId: "u1", participantId: 1, participantName: "A",
                    content: "hi", messageType: .chat, contentType: .text, senderType: .user, createdAt: Date())
        ]
        let (vm, _) = makeVM(getMessagesUseCase: mockUseCase)

        await vm.getMessageList()

        #expect(vm.messageDataList.count == 1)
        #expect(vm.isMessageDataListLoaded == true)
        #expect(mockUseCase.callCount == 1)
    }

    @Test func test_getMessageList_whenError_showsDialog() async {
        let mockUseCase = MockGetMessagesUseCase()
        mockUseCase.shouldThrow = true
        let (vm, _) = makeVM(getMessagesUseCase: mockUseCase)

        await vm.getMessageList()

        #expect(vm.showNetworkErrorDialog == true)
        #expect(vm.messageDataList.isEmpty)
    }

    // MARK: - sendMessage

    @Test func test_sendMessage_whenEmpty_doesNotSend() {
        let (vm, ws) = makeVM()
        vm.inputText = ""

        vm.sendMessage()

        #expect(ws.sendMessageCallCount == 0)
        #expect(vm.showNetworkErrorDialog == false)
    }

    @Test func test_sendMessage_success_clearsInput() {
        let (vm, _) = makeVM()
        vm.inputText = "안녕하세요"

        vm.sendMessage()

        #expect(vm.inputText == "")
    }

    @Test func test_sendMessage_whenSocketError_showsDialog() {
        let (vm, ws) = makeVM()
        ws.shouldThrow = true
        vm.inputText = "테스트"

        vm.sendMessage()

        #expect(vm.showNetworkErrorDialog == true)
    }

    // MARK: - onMessageReceived callback

    @Test func test_onMessageReceived_insertsAtFront() {
        let (vm, ws) = makeVM()
        let existing = Message(id: 1, roomId: 1, userId: "u1", participantId: 1, participantName: "A",
                               content: "old", messageType: .chat, contentType: .text, senderType: .user, createdAt: Date())
        vm.messageDataList = [existing]

        let newMessage = Message(id: 99, roomId: 1, userId: "u1", participantId: 1, participantName: "A",
                                 content: "new", messageType: .chat, contentType: .text, senderType: .user, createdAt: Date())
        ws.onMessageReceivedHandler?(newMessage)

        #expect(vm.messageDataList.first?.id == 99)
        #expect(vm.messageDataList.count == 2)
    }

    // MARK: - shouldDismiss

    @Test func test_exitRoom_setssShouldDismiss() async {
        let (vm, _) = makeVM()

        await vm.exitRoom()

        #expect(vm.shouldDismiss == true)
    }

    @Test func test_tempExit_setsShouldDismiss() {
        let (vm, _) = makeVM()

        vm.tempExit()

        #expect(vm.shouldDismiss == true)
    }

    // MARK: - reportUser

    @Test func test_reportUser_callsUseCase() async {
        let mockReport = MockReportUserUseCase()
        let mockDetail = MockGetRoomDetailUseCase()
        mockDetail.mockRoomDetail = RoomDetail(
            id: 1, title: "방", type: .normal,
            participants: [
                Participant(userId: "test-user", name: "나"),
                Participant(userId: "other-user", name: "상대")
            ]
        )
        let (vm, _) = makeVM(getRoomDetailUseCase: mockDetail, reportUserUseCase: mockReport)
        await vm.getRoomDetailData()

        vm.selectedReason = "스팸"
        await vm.reportUser()

        #expect(mockReport.callCount == 1)
        #expect(mockReport.lastReportType == .spam)
    }
}
