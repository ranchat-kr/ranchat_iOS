//
//  ChatScrollView.swift
//  ranchat
//
//  Created by 김견 on 10/9/24.
//

import SwiftUI

struct ChatScrollView: View {
    @Binding var chattingList: [MessageData]
    
    var fetchMessages: () async -> Void
    
    var body: some View {

        ScrollViewReader { proxy in
            List(chattingList.reversed(), id: \.self) { message in
                ChatElementView(
                    id: message.id,
                    userId: message.userId,
                    content: message.content,
                    messageType: message.messageType
                )
                .listRowSeparator(.hidden)
                .onAppear {
                    if message == chattingList.reversed().first {
                        Task {
                            await fetchMessages()
                        }
                    }
                }
            }
            .listStyle(.plain)
            .onChange(of: chattingList.reversed()) { oldValue, newValue in
                if oldValue.isEmpty {
                    proxy.scrollTo(chattingList.reversed().last?.id, anchor: .bottom)
                } else {
                    proxy.scrollTo(oldValue.first?.id, anchor: .top)
                }
            }
        }
    }
}


#Preview {
    ChatScrollView(chattingList: .constant([]), fetchMessages: {})
}
