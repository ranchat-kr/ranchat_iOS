//
//  ChattingView.swift
//  ranchat
//
//  Created by 김견 on 10/9/24.
//

import SwiftUI

struct ChattingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(IdHelper.self) var idHelper
    @Environment(WebSocketHelper.self) var webSocketHelper
    @State var isTextFieldFocused: Bool = true
    @State var keyboardHeight: CGFloat = 0 {
        didSet {
            print("keyboardHeight: \(keyboardHeight)")
        }
    }
    @State var viewModel = ChattingViewModel()
    
    var body: some View {
        ZStack {
            VStack {
                ChatScrollView(chattingList: $viewModel.messageDataList, fetchMessages: viewModel.fetchMessageList)
                    //.padding(.bottom, keyboardHeight)
                    
                
                ChatInputView(inputText: $viewModel.inputText, chattingList: $viewModel.messageDataList, isFocused: $isTextFieldFocused, onSend: send)
            }
            .onTapGesture {
                isTextFieldFocused = false
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    ToolbarButton(action: {
                        dismiss()
                    }, imageName: "chevron.backward")
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    // 신고 버튼
                    if viewModel.roomDetailData?.type != "GPT" {
                        ToolbarButton(action: {
                            viewModel.showReportDialog = true
                        }, imageName: "exclamationmark.bubble.fill")
                    }
                    
                    // 나가기 버튼
                    ToolbarButton(action: {
                        viewModel.showExitDialog = true
                    }, imageName: "iphone.and.arrow.right.outward")
                }
                ToolbarItem(placement: .principal) {
                    Text(viewModel.roomDetailData?.title ?? "")
                        .font(.dungGeunMo24)
                }
            }
            .navigationBarBackButtonHidden()
            .navigationBarTitleDisplayMode(.inline)
            
            if viewModel.showReportDialog {
                ReportDialogView(
                    isPresented: $viewModel.showReportDialog,
                    selectedReason: $viewModel.selectedReason,
                    reportText: $viewModel.reportText,
                    onReport: viewModel.reportUser
                )
            }
            
            if viewModel.showExitDialog {
                ExitDialogView(
                    isPresented: $viewModel.showExitDialog,
                    onConfirm: {
                        Task {
                            await viewModel.exitRoom()
                            dismiss()
                        }
                    }
                )
            }
            
            if viewModel.isLoading {
                CenterLoadingView()
            }
        }
        .onAppear {
            Task {
                viewModel.setHelper(webSocketHelper, idHelper)
                viewModel.webSocketHelper?.setChattingViewModel(viewModel)
                await viewModel.getRoomDetailData()
                await viewModel.getMessageList()
            }
        }
    }
    
    func send() {
        viewModel.sendMessage()
    }
}

#Preview {
    ChattingView()
}
