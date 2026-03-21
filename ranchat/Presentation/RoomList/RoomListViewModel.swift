//
//  RoomListViewModel.swift
//  ranchat
//

import Foundation

@Observable
class RoomListViewModel {
    let className = "RoomListViewModel"

    var isLoading: Bool = false
    var isInitialized: Bool = false

    var showExitRoomDialog: Bool = false
    var showNetworkErrorDialog: Bool = false
    var goToChat: Bool = false

    var roomPage = 0
    var roomItems: [Room] = []

    var selectedRoom: Room?
    var selectedRoomIndex: Int?

    var webSocketService: (any WebSocketService)?
    var idHelper: IdHelper?
    var networkMonitor: NetworkMonitor?

    private var getRoomsUseCase: any GetRoomsUseCase

    init(getRoomsUseCase: any GetRoomsUseCase = DefaultGetRoomsUseCase()) {
        self.getRoomsUseCase = getRoomsUseCase
    }

    func setup(webSocketService: any WebSocketService, idHelper: IdHelper, networkMonitor: NetworkMonitor) {
        self.webSocketService = webSocketService
        self.idHelper = idHelper
        self.networkMonitor = networkMonitor
    }

    func navigateToChat() {
        goToChat = true
    }

    // MARK: - Require Network

    func getRoomList(isRefresh: Bool = false) async {
        guard let userId = idHelper?.getUserId() else {
            Logger.shared.log(className, #function, "userId is nil", .error)
            return
        }

        do {
            var roomPage: RoomPage
            if isRefresh {
                roomItems.removeAll()
                roomPage = try await getRoomsUseCase.execute(userId: userId, page: 0, size: (self.roomPage + 1) * 10)
            } else {
                roomPage = try await getRoomsUseCase.execute(userId: userId, page: self.roomPage, size: 10)
                self.roomPage += 1
            }
            if roomPage.totalCount == roomItems.count {
                isLoading = false
                return
            }
            roomItems.append(contentsOf: roomPage.items)
            self.isInitialized = true
        } catch {
            Logger.shared.log(className, #function, "Failed to get room list: \(error.localizedDescription)", .error)
            showNetworkErrorDialog = true
        }
    }

    func enterRoom(at: Int) {
        if !(networkMonitor?.isConnected ?? false) {
            showNetworkErrorDialog = true
            return
        }

        let roomId: String = String(roomItems[at].id)

        guard let webSocketService, let idHelper else {
            Logger.shared.log(className, #function, "webSocketService or idHelper nil", .error)
            return
        }

        idHelper.setRoomId(roomId)

        guard let userId = idHelper.getUserId() else {
            Logger.shared.log(className, #function, "userId is nil", .error)
            return
        }

        do {
            try webSocketService.enterRoom(userId: userId, roomId: roomId)
            navigateToChat()
        } catch {
            Logger.shared.log(className, #function, "Failed to enter room: \(error.localizedDescription)", .error)
            showNetworkErrorDialog = true
        }
    }

    func exitRoom(at: Int) {
        if !(networkMonitor?.isConnected ?? false) {
            showNetworkErrorDialog = true
            return
        }

        let roomId: String = String(roomItems[at].id)

        guard let webSocketService,
              let userId = idHelper?.getUserId() else {
            Logger.shared.log(className, #function, "webSocketService or idHelper is nil", .error)
            showNetworkErrorDialog = true
            return
        }

        do {
            try webSocketService.exitRoom(userId: userId, roomId: roomId)
            roomItems.remove(at: at)
        } catch {
            Logger.shared.log(className, #function, "Failed to exit room: \(error.localizedDescription)", .error)
            showNetworkErrorDialog = true
        }
    }
}
