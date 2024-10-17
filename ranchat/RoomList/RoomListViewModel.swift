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
    
    var roomPage = 0
    var roomList: RoomDataList?
    
    func getRoomList() async {
        isLoading = true
        
        do {
            roomList = try await ApiHelper.shared.getRooms(page: roomPage, size: 10)
            roomPage += 1
        } catch {
            print("DEBUG: RoomListViewModel.getRoomList() error: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
}
