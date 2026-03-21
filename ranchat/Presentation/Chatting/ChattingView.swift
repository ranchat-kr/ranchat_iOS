//
//  ChattingView.swift
//  ranchat
//

import SwiftUI

struct ChattingView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(IdHelper.self) var idHelper
    @Environment(WebSocketHelper.self) var webSocketHelper
    @Environment(NetworkMonitor.self) var networkMonitor
    @State var isTextFieldFocused: Bool = true
    @State var isReportDialogTextFieldFocused: Bool = false
    @State var timer: Timer?
    @State var viewModel = ChattingViewModel()

    var body: some View {
        ZStack {
            VStack {
                ChatScrollView(chattingList: $viewModel.messageDataList, fetchMessages: viewModel.fetchMessageList)

                ChatInputView(inputText: $viewModel.inputText, isFocused: $isTextFieldFocused, onSend: send)
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
                    if viewModel.roomDetailData?.type != .gpt {
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
                viewModel.setup(webSocketService: webSocketHelper, idHelper: idHelper, networkMonitor: networkMonitor)
                await viewModel.getRoomDetailData()
                await viewModel.getMessageList()
                startTimer()
            }
        }
        .onChange(of: viewModel.shouldDismiss) { _, newValue in
            if newValue { dismiss() }
        }
        .onDisappear {
            activateParticipant()
            stopTimer()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            stopTimer()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            if timer == nil {
                startTimer()
            }
        }
        .onChange(of: networkMonitor.isConnected) { oldValue, newValue in
            if oldValue == false && newValue == true {
                Task {
                    if !viewModel.isRoomDetailDataLoaded {
                        await viewModel.getRoomDetailData()
                    }
                    if !viewModel.isMessageDataListLoaded {
                        await viewModel.getMessageList()
                    }
                }
            }
        }
        .onChange(of: viewModel.showReportDialog, { oldValue, newValue in
            if newValue {
                isTextFieldFocused = false
            }
        })
        .dialog(
            isPresented: $viewModel.showNetworkErrorDialog,
            title: viewModel.networkErrorTitle,
            content: viewModel.networkErrorContent,
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

    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true, block: { _ in
            activateParticipant()
        })
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    func activateParticipant() {
        viewModel.activateParticipant()
    }
}

#Preview {
    ChattingView()
}
