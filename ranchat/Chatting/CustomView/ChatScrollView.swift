//
//  ChatScrollView.swift
//  ranchat
//
//  Created by 김견 on 10/9/24.
//

import SwiftUI

struct ChatScrollView: View {
    @Binding var chattingList: [MessageData]
    
    var body: some View {
        ScrollViewReader { scrollViewProxy in
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(chattingList.reversed(), id: \.id) { message in
                        let content = message.content
                        let id = message.id
                        
                        ChatElementView(id: id, userId: message.userId, content: content, messageType: message.messageType)
                    }
                }
                .padding(.horizontal)
            }
            .onChange(of: chattingList) { _ in
                if let lastMessage = chattingList.first {
                    withAnimation {
                        scrollViewProxy.scrollTo(lastMessage.id, anchor: .top)
                    }
                }
            }
            .onAppear {
                if let lastMessage = chattingList.first {
                    scrollViewProxy.scrollTo(lastMessage.id, anchor: .top)
                }
            }
        }
    }
}

#Preview {
    ChatScrollView(chattingList: .constant([]))
}
