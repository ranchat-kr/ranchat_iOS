//
//  RoomListViewModel.swift
//  ranchat
//

import Foundation

@MainActor
@Observable
class RoomListViewModel {
    let className = "RoomListViewModel"

    var isLoading: Bool = false
    var isInitialized: Bool = false

    var showExitRoomDialog: Bool = false
    var showNetworkErrorDialog: Bool = false
    var networkErrorTitle: String = "오류"
    var networkErrorContent: String = "알 수 없는 오류가 발생했습니다."
    var goToChat: Bool = false

    var roomPage = 0
    var roomItems: [Room] = []

    var selectedRoom: Room?
    var selectedRoomIndex: Int?
    var selectedRoomId: String = ""

    var webSocketService: (any WebSocketService)?
    var networkMonitor: NetworkMonitor?

    private var getRoomsUseCase: any GetRoomsUseCase

    init(getRoomsUseCase: any GetRoomsUseCase = DefaultGetRoomsUseCase()) {
        self.getRoomsUseCase = getRoomsUseCase
    }

    func setup(webSocketService: any WebSocketService, networkMonitor: NetworkMonitor) {
        self.webSocketService = webSocketService
        self.networkMonitor = networkMonitor
    }

    func navigateToChat() {
        goToChat = true
    }

    // MARK: - Require Network

    func getRoomList(isRefresh: Bool = false) async {
        guard let userId = KeychainHelper.shared.getUserId() else {
            Logger.shared.log(className, #function, "userId is nil", .error)
            return
        }

        isLoading = true
        do {
            var roomPage: RoomPage
            if isRefresh {
                let pagesToLoad = max(self.roomPage, 1)
                roomItems.removeAll()
                roomPage = try await getRoomsUseCase.execute(userId: userId, page: 0, size: pagesToLoad * 10)
                self.roomPage = pagesToLoad
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
            isLoading = false
        } catch let apiError as ApiHelperError {
            Logger.shared.log(className, #function, "Failed to get room list: \(apiError)", .error)
            networkErrorTitle = apiError.dialogTitle
            networkErrorContent = apiError.dialogContent
            showNetworkErrorDialog = true
            isLoading = false
        } catch {
            Logger.shared.log(className, #function, "Failed to get room list: \(error.localizedDescription)", .error)
            networkErrorTitle = "오류"
            networkErrorContent = "알 수 없는 오류가 발생했습니다."
            showNetworkErrorDialog = true
            isLoading = false
        }
    }

    func enterRoom(at: Int) {
        if !(networkMonitor?.isConnected ?? false) {
            networkErrorTitle = "네트워크 오류"
            networkErrorContent = "인터넷 연결을 확인해주세요."
            showNetworkErrorDialog = true
            return
        }

        guard at < roomItems.count else {
            Logger.shared.log(className, #function, "Index out of bounds: \(at)", .error)
            return
        }

        let roomId: String = String(roomItems[at].id)

        guard let webSocketService,
              let userId = KeychainHelper.shared.getUserId() else {
            Logger.shared.log(className, #function, "webSocketService or userId is nil", .error)
            return
        }

        do {
            try webSocketService.enterRoom(userId: userId, roomId: roomId)
            selectedRoomId = roomId
            navigateToChat()
        } catch let apiError as ApiHelperError {
            Logger.shared.log(className, #function, "Failed to enter room: \(apiError)", .error)
            networkErrorTitle = apiError.dialogTitle
            networkErrorContent = apiError.dialogContent
            showNetworkErrorDialog = true
        } catch {
            Logger.shared.log(className, #function, "Failed to enter room: \(error.localizedDescription)", .error)
            networkErrorTitle = "오류"
            networkErrorContent = "알 수 없는 오류가 발생했습니다."
            showNetworkErrorDialog = true
        }
    }

    func exitRoom(at: Int) {
        if !(networkMonitor?.isConnected ?? false) {
            networkErrorTitle = "네트워크 오류"
            networkErrorContent = "인터넷 연결을 확인해주세요."
            showNetworkErrorDialog = true
            return
        }

        guard at < roomItems.count else {
            Logger.shared.log(className, #function, "Index out of bounds: \(at)", .error)
            return
        }

        let roomId: String = String(roomItems[at].id)

        guard let webSocketService,
              let userId = KeychainHelper.shared.getUserId() else {
            Logger.shared.log(className, #function, "webSocketService or userId is nil", .error)
            networkErrorTitle = "오류"
            networkErrorContent = "필요한 정보를 찾을 수 없습니다."
            showNetworkErrorDialog = true
            return
        }

        do {
            try webSocketService.exitRoom(userId: userId, roomId: roomId)
            roomItems.remove(at: at)
            if roomItems.count < roomPage * 10 {
                roomPage = max(0, roomPage - 1)
            }
        } catch let apiError as ApiHelperError {
            Logger.shared.log(className, #function, "Failed to exit room: \(apiError)", .error)
            networkErrorTitle = apiError.dialogTitle
            networkErrorContent = apiError.dialogContent
            showNetworkErrorDialog = true
        } catch {
            Logger.shared.log(className, #function, "Failed to exit room: \(error.localizedDescription)", .error)
            networkErrorTitle = "오류"
            networkErrorContent = "알 수 없는 오류가 발생했습니다."
            showNetworkErrorDialog = true
        }
    }
}
