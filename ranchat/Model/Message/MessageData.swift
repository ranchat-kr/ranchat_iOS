//
//  MessageData.swift
//  ranchat
//
//  Created by 김견 on 9/29/24.
//

import Foundation

struct MessageData: Codable, Identifiable, Equatable, Hashable {
    var id: Int
    var roomId: Int
    var userId: String
    var participantId: Int
    var participantName: String
    var content: String
    var messageType: String
    var contentType: String
    var senderType: String
    var createdAt: String
    
    init?(jsonString: [String: AnyObject]) {
        let decoder = JSONDecoder()

        // JSON 딕셔너리를 Data로 변환
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonString, options: [])
            
            // JSON 데이터를 디코딩하여 MessageData로 변환
            let messageData = try decoder.decode(MessageData.self, from: jsonData)
            self = messageData
        } catch {
            print("DEBUG: MessageData decoding error: \(error.localizedDescription)")
            return nil
        }
    }
}

