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
    var roomItems: [RoomData] = [
//        RoomData(id: 0, title: "qdqd", type: "dqdwq", latestMessage: "dsadad", latestMessageAt: "2024-10-17T21:13:22"),
//        RoomData(id: 1, title: "qdqd", type: "dqdwq", latestMessage: "dsadad", latestMessageAt: "2024-10-17T21:13:22"),
//        RoomData(id: 2, title: "qdqd", type: "dqdwq", latestMessage: "dsadad", latestMessageAt: "2024-10-17T21:13:22"),
//        RoomData(id: 3, title: "qdqd", type: "dqdwq", latestMessage: "dsadad", latestMessageAt: "2024-10-17T21:13:22"),
//        RoomData(id: 4, title: "qdqd", type: "dqdwq", latestMessage: "dsadad", latestMessageAt: "2024-10-17T21:13:22"),
//        RoomData(id: 5, title: "qdqd", type: "dqdwq", latestMessage: "dsadad", latestMessageAt: "2024-10-17T21:13:22"),
//        RoomData(id: 6, title: "qdqd", type: "dqdwq", latestMessage: "dsadad", latestMessageAt: "2024-10-17T21:13:22"),
//        RoomData(id: 7, title: "qdqd", type: "dqdwq", latestMessage: "dsadad", latestMessageAt: "2024-10-17T21:13:22"),
//        RoomData(id: 8, title: "qdqd", type: "dqdwq", latestMessage: "dsadad", latestMessageAt: "2024-10-17T21:13:22"),
//        RoomData(id: 9, title: "qdqd", type: "dqdwq", latestMessage: "dsadad", latestMessageAt: "2024-10-17T21:13:22"),
//        RoomData(id: 10, title: "qdqd", type: "dqdwq", latestMessage: "dsadad", latestMessageAt: "2024-10-17T21:13:22"),
//        RoomData(id: 11, title: "qdqd", type: "dqdwq", latestMessage: "dsadad", latestMessageAt: "2024-10-17T21:13:22"),
//        RoomData(id: 12, title: "qdqd", type: "dqdwq", latestMessage: "dsadad", latestMessageAt: "2024-10-17T21:13:22"),
//        RoomData(id: 13, title: "qdqd", type: "dqdwq", latestMessage: "dsadad", latestMessageAt: "2024-10-17T21:13:22"),
//        RoomData(id: 14, title: "qdqd", type: "dqdwq", latestMessage: "dsadad", latestMessageAt: "2024-10-17T21:13:22"),
//        RoomData(id: 15, title: "qdqd", type: "dqdwq", latestMessage: "dsadad", latestMessageAt: "2024-10-17T21:13:22"),
//        RoomData(id: 16, title: "qdqd", type: "dqdwq", latestMessage: "dsadad", latestMessageAt: "2024-10-17T21:13:22"),
//        RoomData(id: 17, title: "qdqd", type: "dqdwq", latestMessage: "dsadad", latestMessageAt: "2024-10-17T21:13:22"),
//        RoomData(id: 18, title: "qdqd", type: "dqdwq", latestMessage: "dsadad", latestMessageAt: "2024-10-17T21:13:22"),
//        RoomData(id: 19, title: "qdqd", type: "dqdwq", latestMessage: "dsadad", latestMessageAt: "2024-10-17T21:13:22"),
//        RoomData(id: 20, title: "qdqd", type: "dqdwq", latestMessage: "dsadad", latestMessageAt: "2024-10-17T21:13:22"),
    ]
    
    func getRoomList() async {
        isLoading = true
        
        do {
            let roomList = try await ApiHelper.shared.getRooms(page: roomPage, size: 10)
            if roomList.data.totalCount == roomItems.count {
                return
            }
            roomPage += 1
            roomItems.append(contentsOf: roomList.data.items)
            print("roomcount: \(roomItems.count), roomList: \(roomList)")
            try await Task.sleep(for: .seconds(2))
        } catch {
            print("DEBUG: RoomListViewModel.getRoomList() error: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
}
