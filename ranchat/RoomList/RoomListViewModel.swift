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
    
    var roomPage = 0
    var roomItems: [RoomData] = []
    
    var selectedRoom: RoomData?
    var selectedRoomIndex: Int?
    
    var webSocketHelper: WebSocketHelper?
    
    func setHelper(_ webSocketHelper: WebSocketHelper) {
        self.webSocketHelper = webSocketHelper
    }
    
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
