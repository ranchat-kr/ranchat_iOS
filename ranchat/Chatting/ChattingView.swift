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
            ChatScrollView(chattingList: $viewModel.chattingList)
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
