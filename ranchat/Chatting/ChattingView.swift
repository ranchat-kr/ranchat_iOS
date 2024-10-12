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
        ZStack {
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
                    // 신고 버튼
                    Button {
                        viewModel.showReportDialog = true
                    } label: {
                        Image(systemName: "exclamationmark.bubble.fill")
                            .tint(.white)
                    }
                    
                    // 나가기 버튼
                    Button {
                        viewModel.showExitDialog = true
                    } label: {
                        Image(systemName: "iphone.and.arrow.right.outward")
                            .tint(.white)
                    }
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
        }
    }
    
    func send() {
        viewModel.chattingList.append(MessageData(id: idCount, content: viewModel.inputText))
    }
}

#Preview {
    ChattingView()
}
