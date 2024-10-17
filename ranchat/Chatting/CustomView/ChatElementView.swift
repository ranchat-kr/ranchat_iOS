//
//  ChatElementView.swift
//  ranchat
//
//  Created by 김견 on 10/9/24.
//

import SwiftUI

enum MessageTypeForColor: String {
    case enter = "ENTER"
    case leave = "LEAVE"
    case other
    case me
}

struct ChatElementView: View {
    @Environment(IdHelper.self) var idHelper
    let id: Int
    let userId: String
    let content: String
    let messageType: String
    
    private var messageTypeForOption: MessageTypeForColor {
        switch messageType {
        case MessageTypeForColor.enter.rawValue:
            return .enter
        case MessageTypeForColor.leave.rawValue:
            return .leave
        default:
            return idHelper.getUserId() == userId ? .me : .other
        }
    }
    
    private var sender: String {
        (messageTypeForOption == .other || messageTypeForOption == .me) ? (idHelper.getUserId() == userId ? "나: " : "상대방: ") : ""
    }
    
    var body: some View {
        Text("\(sender)\(content)")
            .font(.dungGeunMo16)
            .padding(.vertical, 4)
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(colorForMessageType())
            .id(id)
    }
    
    private func colorForMessageType() -> Color {
        switch messageTypeForOption {
        case .enter:
            return .cyan
        case .leave:
            return .red
        case .me:
            return .yellow
        default:
            return .white
        }
    }
}

#Preview {
    ChatElementView(id: 1, userId: "testUser", content: "안녕하세요!", messageType: "ENTER")
}

