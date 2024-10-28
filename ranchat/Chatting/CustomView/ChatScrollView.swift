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
            
            List(chattingList, id: \.id) { message in
                ChatElementView(
                    id: message.id,
                    userId: message.userId,
                    content: message.content,
                    messageType: message.messageType
                )
                .scaleEffect(x: 1, y: -1)
                .listRowSeparator(.hidden)
                .onAppear {
                    
                    if chattingList.count >= 25 && message == chattingList[chattingList.count - 25] {
                        Task {
                            await fetchMessages()
                        }
                    }
                }
            }
            .scaleEffect(x: 1, y: -1)
            .listStyle(.plain)
            .onChange(of: chattingList) { oldValue, newValue in
                if oldValue.isEmpty {
                    proxy.scrollTo(chattingList.first?.id, anchor: .bottom)
                } else if newValue.count - oldValue.count == 1 {
                    proxy.scrollTo(newValue.first?.id, anchor: .bottom)
                }
            }
            
        }
    }
}


#Preview {
    ChatScrollView(chattingList: .constant([]),  fetchMessages: {})
}
