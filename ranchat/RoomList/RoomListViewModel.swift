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
    var isInitialLized: Bool = false
    
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
    
    func setHelper(_ webSocketHelper: WebSocketHelper,_ idHelper: IdHelper) {
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
        //isLoading = true
        
        do {
            var roomList: RoomDataList
            if isRefresh {
                roomItems.removeAll()
                roomList = try await ApiHelper.shared.getRooms(page: 0, size: (roomPage + 1) * 10)
            } else {
                roomList = try await ApiHelper.shared.getRooms(page: roomPage, size: 10)
                roomPage += 1
            }
            if roomList.data.totalCount == roomItems.count {
                isLoading = false
                return
            }
            roomItems.append(contentsOf: roomList.data.items)
            self.isInitialLized = true
        } catch {
            Logger.shared.log(self.className, #function, "Failed to get room list: \(error.localizedDescription)", .error)
            showNetworkErrorDialog = true
        }
        
        // isLoading = false
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
