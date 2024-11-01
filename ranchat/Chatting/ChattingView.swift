//
//  ChattingView.swift
//  ranchat
//
//  Created by 김견 on 10/9/24.
//

import SwiftUI

struct ChattingView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(IdHelper.self) var idHelper
    @Environment(WebSocketHelper.self) var webSocketHelper
    @Environment(NetworkMonitor.self) var networkMonitor
    @State var isTextFieldFocused: Bool = true
    @State var isReportDialogTextFieldFocused: Bool = false
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
                        viewModel.tempExit()
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
            .ignoresSafeArea(.keyboard, edges: isReportDialogTextFieldFocused ? .bottom : [])
            
            if viewModel.showReportDialog {
                ReportDialogView(
                    isPresented: $viewModel.showReportDialog,
                    selectedReason: $viewModel.selectedReason,
                    reportText: $viewModel.reportText,
                    isFocused: $isReportDialogTextFieldFocused,
                    onReport: viewModel.reportUser
                )
            }
            
            if viewModel.isLoading {
                CenterLoadingView()
            }
        }
        .onAppear {
            Task {
                viewModel.setHelper(webSocketHelper, idHelper)
                viewModel.setDismiss {
                    DispatchQueue.main.async {
                        dismiss()
                    }
                }
                viewModel.setNetworkMonitor(networkMonitor)
                viewModel.webSocketHelper?.setChattingViewModel(viewModel)
                await viewModel.getRoomDetailData()
                await viewModel.getMessageList()
            }
        }
        .onChange(of: networkMonitor.isConnected) { oldValue, newValue in
            if oldValue == false && newValue == true {  // 네트워크가 연결 되었을 때
                
            }
        }
        .onChange(of: viewModel.showReportDialog, { oldValue, newValue in
            if newValue {
                isTextFieldFocused = false
            }
        })
        .dialog(
            isPresented: $viewModel.showNetworkErrorAlert,
            title: "인터넷 연결 오류",
            content: "인터넷 연결을 확인해주세요.",
            primaryButtonText: "확인",
            onPrimaryButton: {}
            )
        
        .dialog(
            isPresented: $viewModel.showExitDialog,
            title: "방 나가기",
            content: "채팅방을 나가시겠습니까?",
            primaryButtonText: "나가기",
            secondaryButtonText: "취소") {
                Task {
                    await viewModel.exitRoom()
                }
                viewModel.showExitDialog = false
            }
    }
    
    func send() {
        viewModel.sendMessage()
    }
}

#Preview {
    ChattingView()
}
