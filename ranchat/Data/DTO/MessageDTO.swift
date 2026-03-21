//
//  MessageDTO.swift
//  ranchat
//

import Foundation

struct MessageDTO: Codable {
    let id: Int
    let roomId: Int
    let userId: String
    let participantId: Int
    let participantName: String
    let content: String
    let messageType: String
    let contentType: String
    let senderType: String
    let createdAt: String

    private static let isoFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    init?(jsonString: [String: AnyObject]) {
        let decoder = JSONDecoder()
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonString, options: [])
            let dto = try decoder.decode(MessageDTO.self, from: jsonData)
            self = dto
        } catch {
            Logger.shared.log("MessageDTO", #function, "Failed to decode: \(error.localizedDescription)", .error)
            return nil
        }
    }

    func toDomain() -> Message {
        Message(
            id: id,
            roomId: roomId,
            userId: userId,
            participantId: participantId,
            participantName: participantName,
            content: content,
            messageType: MessageType(rawValue: messageType) ?? .unknown,
            contentType: ContentType(rawValue: contentType) ?? .unknown,
            senderType: SenderType(rawValue: senderType) ?? .unknown,
            createdAt: Self.isoFormatter.date(from: createdAt) ?? Date()
        )
    }
}
