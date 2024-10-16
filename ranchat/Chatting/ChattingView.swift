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
    @State var viewModel = ChattingViewModel()
    var idCount = 100
    
    var body: some View {
        ZStack {
            VStack {
                ChatScrollView(chattingList: $viewModel.messageDataList)
                ChatInputView(inputText: $viewModel.inputText, chattingList: $viewModel.messageDataList, onSend: send)
            }
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
                    // 신고 버튼
                    Button {
                        viewModel.showReportDialog = true
                    } label: {
                        if viewModel.roomDetailData?.type != "GPT" {
                            Image(systemName: "exclamationmark.bubble.fill")
                                .tint(.white)
                        }
                    }
                    
                    // 나가기 버튼
                    Button {
                        viewModel.showExitDialog = true
                    } label: {
                        Image(systemName: "iphone.and.arrow.right.outward")
                            .tint(.white)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text(viewModel.roomDetailData?.title ?? "")
                        .font(.dungGeunMo32)
                }
            }
            .navigationBarBackButtonHidden()
            
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
                await viewModel.getRoomDetailData()
            }
        }
    }
    
    func send() {
        viewModel.messageDataList.append(MessageData(id: idCount, content: viewModel.inputText))
    }
}

#Preview {
    ChattingView()
}
