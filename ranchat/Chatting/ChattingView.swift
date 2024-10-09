//
//  ChattingView.swift
//  ranchat
//
//  Created by 김견 on 10/9/24.
//

import SwiftUI

struct ChattingView: View {
    @Environment(\.dismiss) private var dismiss
    @State var viewModel = ChattingViewModel()
    var idCount = 100
    
    var body: some View {
        VStack {
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(viewModel.chattingList, id: \.id) { message in
                            let content = message.content
                            let id = message.id
                            
                            Text(content)
                                .font(.dungGeunMo16)
                                .padding(.vertical, 4)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .id(id)
                        }
                    }
                    .padding(.horizontal)
                }
                .onChange(of: viewModel.chattingList) { _ in
                    if let lastMessage = viewModel.chattingList.last {
                        withAnimation {
                            scrollViewProxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
                .onAppear {
                    if let lastMessage = viewModel.chattingList.last {
                        scrollViewProxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
            ChatInputView(inputText: $viewModel.inputText, chattingList: $viewModel.chattingList, onSend: send)
        }
        .navigationTitle(viewModel.roomDetailData?.title ?? "")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .tint(.white)
                }
            }
            ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        // Add functionality here
                    } label: {
                        Image(systemName: "iphone.and.arrow.right.outward")
                            .tint(.white)
                    }

                    Button {
                        // Add functionality here
                    } label: {
                        Image(systemName: "exclamationmark.bubble.fill")
                            .tint(.white)
                    }
                }
        }
        .navigationBarBackButtonHidden()
    }
    
    func send() {
        viewModel.chattingList.append(MessageData(id: idCount, content: viewModel.inputText))
    }
}

#Preview {
    ChattingView()
}
