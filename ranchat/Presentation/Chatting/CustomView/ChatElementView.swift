//
//  ChatElementView.swift
//  ranchat
//

import SwiftUI

private enum MessageDisplayType {
    case enter, leave, me, other
}

struct ChatElementView: View {
    @Environment(IdHelper.self) var idHelper
    let id: Int
    let userId: String
    let content: String
    let messageType: MessageType

    private var displayType: MessageDisplayType {
        switch messageType {
        case .enter:
            return .enter
        case .leave:
            return .leave
        case .chat, .unknown:
            return idHelper.getUserId() == userId ? .me : .other
        }
    }

    private var sender: String {
        switch displayType {
        case .me: return "나: "
        case .other: return "상대방: "
        case .enter, .leave: return ""
        }
    }

    var body: some View {
        Text("\(sender)\(content)")
            .font(.dungGeunMo16)
            .padding(.vertical, 4)
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(colorForDisplayType())
            .id(id)
    }

    private func colorForDisplayType() -> Color {
        switch displayType {
        case .enter:
            return .cyan
        case .leave:
            return .red
        case .me:
            return .yellow
        case .other:
            return .white
        }
    }
}

#Preview {
    ChatElementView(id: 1, userId: "testUser", content: "안녕하세요!", messageType: .enter)
}
