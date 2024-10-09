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
}

struct ChatElementView: View {
    @Environment(IdHelper.self) var idHelper
    let id: Int
    let userId: String
    let content: String
    let messageType: String
    
    @State private var messageTypeForColor: MessageTypeForColor = .other
    
    var sender: String {
        idHelper.getUserId() == userId ? "나" : "상대방"
    }
    
    var body: some View {
        Text(content)
            .font(.dungGeunMo16)
            .padding(.vertical, 4)
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(colorForMessageType())
            .id(id)
            .onAppear {
                setType()
            }
    }
    
    private func setType() {
        if messageType == MessageTypeForColor.enter.rawValue {
            messageTypeForColor = .enter
        } else if messageType == MessageTypeForColor.leave.rawValue {
            messageTypeForColor = .leave
        } else {
            messageTypeForColor = .other
        }
    }
    
    private func colorForMessageType() -> Color {
        switch messageTypeForColor {
        case .enter:
            return .cyan
        case .leave:
            return .red
        default:
            return .white
        }
    }
}

#Preview {
    ChatElementView(id: 1, userId: "testUser", content: "안녕하세요!", messageType: "ENTER")
}

