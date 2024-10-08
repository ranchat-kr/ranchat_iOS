//
//  IdHelper.swift
//  ranchat
//
//  Created by 김견 on 10/8/24.
//

import SwiftUI

@Observable
class IdHelper {
    private var userId: String?
    private var roomId: String?
    
    func setUserId(_ userId: String) {
        self.userId = userId
    }
    
    func setRoomId(_ roomId: String) {
        self.userId = roomId
    }
    
    func getUserId() -> String? {
        return userId
    }
    
    func getRoomId() -> String? {
        return roomId
    }
}
