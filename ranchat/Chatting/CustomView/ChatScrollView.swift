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
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(chattingList, id: \.id) { message in
                        let content = message.content
                        let id = message.id
                        
//                            Text(content)
//                                .font(.dungGeunMo16)
//                                .padding(.vertical, 4)
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                                .id(id)
                        ChatElementView(id: id, userId: message.userId ?? "", content: content, messageType: message.messageType ?? "")
                    }
                }
                .padding(.horizontal)
            }
            .onChange(of: chattingList) { _ in
                if let lastMessage = chattingList.last {
                    withAnimation {
                        scrollViewProxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
            .onAppear {
                if let lastMessage = chattingList.last {
                    scrollViewProxy.scrollTo(lastMessage.id, anchor: .bottom)
                }
            }
        }
    }
}

#Preview {
    ChatScrollView(chattingList: .constant([]))
}
