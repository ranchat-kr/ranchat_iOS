//
//  RoomListViewModel.swift
//  ranchat
//
//  Created by 김견 on 10/17/24.
//
import Foundation

@Observable
class RoomListViewModel {
    var isLoading: Bool = false
    var showExitRoomDialog: Bool = false
    var goToChat: Bool = false
    
    var roomPage = 0
    var roomItems: [RoomData] = []
    
    var selectedRoom: RoomData?
    var selectedRoomIndex: Int?
    
    var webSocketHelper: WebSocketHelper?
    var idHelper: IdHelper?
    
    func setHelper(_ webSocketHelper: WebSocketHelper,_ idHelper: IdHelper) {
        self.webSocketHelper = webSocketHelper
        self.idHelper = idHelper
    }
    
    func navigateToChat() {
        goToChat = true
    }
    
    //MARK: - Require Network
    func getRoomList() async {
        isLoading = true

        do {
            let roomList = try await ApiHelper.shared.getRooms(page: roomPage, size: 10)
            if roomList.data.totalCount == roomItems.count {
                isLoading = false
                return
            }
            roomPage += 1
            roomItems.append(contentsOf: roomList.data.items)
            print("roomcount: \(roomItems.count), roomPage: \(roomPage)")
            
//            if roomPage == 1 {
//                try await Task.sleep(for: .seconds(2))
//            }
        } catch {
            print("DEBUG: RoomListViewModel.getRoomList() error: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    func enterRoom(at: Int) {
        let roomId: String = String(roomItems[at].id)
        
        guard let webSocketHelper, let idHelper else {
            print("DEBUG: RoomListViewModel.enterRoom() error: webSocketHelper or idHelper nil")
            return
        }
        
        idHelper.setRoomId(roomId)
        
        do {
            try webSocketHelper.enterRoom()
            navigateToChat()
        } catch {
            print("DEBUG: RoomListViewModel.enterRoom() error: \(error.localizedDescription)")
        }
    }
    
    func exitRoom(at: Int) {
        let roomId: String = String(roomItems[at].id)
        
        if let webSocketHelper {
            do {
                try webSocketHelper.exitRoom(roomId: roomId)
                roomItems.remove(at: at)
            } catch {
                print("DEBUG: RoomListViewModel.exitRoom() error: \(error.localizedDescription)")
            }
        } else {
            print("DEBUG: RoomListViewModel.exitRoom() webSocketHelper is nil")
        }
    }
}
