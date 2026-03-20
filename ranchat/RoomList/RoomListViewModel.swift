//
//  RoomListViewModel.swift
//  ranchat
//
//  Created by 김견 on 10/17/24.
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
    var roomItems: [RoomData] = []

    var selectedRoom: RoomData?
    var selectedRoomIndex: Int?

    var webSocketHelper: WebSocketHelper?
    var idHelper: IdHelper?
    var networkMonitor: NetworkMonitor?

    private var roomRepository: RoomRepository

    init(roomRepository: RoomRepository = DefaultRoomRepository()) {
        self.roomRepository = roomRepository
    }

    func setHelper(_ webSocketHelper: WebSocketHelper, _ idHelper: IdHelper) {
        self.webSocketHelper = webSocketHelper
        self.idHelper = idHelper
    }

    func setNetworkMonitor(_ networkMonitor: NetworkMonitor) {
        self.networkMonitor = networkMonitor
    }

    func navigateToChat() {
        goToChat = true
    }

    //MARK: - Require Network
    func getRoomList(isRefresh: Bool = false) async {
        guard let userId = idHelper?.getUserId() else {
            Logger.shared.log(className, #function, "userId is nil", .error)
            return
        }

        do {
            var roomList: RoomDataList
            if isRefresh {
                roomItems.removeAll()
                roomList = try await roomRepository.getRooms(userId: userId, page: 0, size: (roomPage + 1) * 10)
            } else {
                roomList = try await roomRepository.getRooms(userId: userId, page: roomPage, size: 10)
                roomPage += 1
            }
            if roomList.data.totalCount == roomItems.count {
                isLoading = false
                return
            }
            roomItems.append(contentsOf: roomList.data.items)
            self.isInitialized = true
        } catch {
            Logger.shared.log(self.className, #function, "Failed to get room list: \(error.localizedDescription)", .error)
            showNetworkErrorDialog = true
        }
    }

    func enterRoom(at: Int) {
        if !(networkMonitor?.isConnected ?? false) {
            showNetworkErrorDialog = true
            return
        }

        let roomId: String = String(roomItems[at].id)

        guard let webSocketHelper, let idHelper else {
            Logger.shared.log(self.className, #function, "webSocketHelper or idHelper nil", .error)
            return
        }

        idHelper.setRoomId(roomId)

        do {
            try webSocketHelper.enterRoom()
            navigateToChat()
        } catch {
            Logger.shared.log(self.className, #function, "Failed to enter room: \(error.localizedDescription)", .error)
            showNetworkErrorDialog = true
        }
    }

    func exitRoom(at: Int) {
        if !(networkMonitor?.isConnected ?? false) {
            showNetworkErrorDialog = true
            return
        }

        let roomId: String = String(roomItems[at].id)

        if let webSocketHelper {
            do {
                try webSocketHelper.exitRoom(roomId: roomId)
                roomItems.remove(at: at)
            } catch {
                Logger.shared.log(self.className, #function, "Failed to exit room: \(error.localizedDescription)", .error)
                showNetworkErrorDialog = true
            }
        } else {
            Logger.shared.log(self.className, #function, "webSocketHelper is nil", .error)
            showNetworkErrorDialog = true
        }
    }
}
