//
//  RoomListView.swift
//  ranchat
//

import SwiftUI

struct RoomListView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(IdHelper.self) var idHelper
    @Environment(WebSocketHelper.self) var webSocketHelper
    @Environment(NetworkMonitor.self) var networkMonitor

    @State var viewModel = RoomListViewModel()

    var body: some View {
        ZStack {
            List(Array(viewModel.roomItems.enumerated()), id: \.element.id) { index, roomData in

                RoomItemView(roomData: roomData, action: {
                    viewModel.enterRoom(at: index)
                }, swipeAction: {
                    viewModel.selectedRoom = roomData
                    viewModel.selectedRoomIndex = index
                    viewModel.showExitRoomDialog = true
                })
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .onAppear {
                    if viewModel.roomItems.last?.id == roomData.id {
                        Task {
                            await viewModel.getRoomList()
                        }
                    }
                }
            }
            .refreshable {
                await viewModel.getRoomList(isRefresh: true)
            }
            .animation(.snappy, value: viewModel.roomItems)
            .listStyle(.plain)

            .onAppear {
                viewModel.setup(webSocketService: webSocketHelper, idHelper: idHelper, networkMonitor: networkMonitor)
                Task {
                    await viewModel.getRoomList()
                }
            }
            .onChange(of: networkMonitor.isConnected) { oldValue, newValue in
                if oldValue == false && newValue == true {
                    Task {
                        if !viewModel.isInitialized {
                            await viewModel.getRoomList()
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Continue")
                        .font(.dungGeunMo24)
                }

                ToolbarItem(placement: .topBarLeading) {
                    ToolbarButton(action: {
                        dismiss()
                    }, imageName: "chevron.backward")
                }
            }
            .navigationBarBackButtonHidden()
            .navigationBarTitleDisplayMode(.inline)

            if viewModel.isInitialized && viewModel.roomItems.isEmpty {
                EmptyRoomListView()
            }

            if viewModel.isLoading {
                CenterLoadingView()
            }
        }
        .navigationDestination(isPresented: $viewModel.goToChat, destination: {
            ChattingView()
                .onDisappear {
                    Task {
                        await viewModel.getRoomList(isRefresh: true)
                    }
                }
        })
        .dialog(
            isPresented: $viewModel.showExitRoomDialog,
            title: "방 나가기",
            content: "'\(viewModel.selectedRoom?.title ?? "")'\n 채팅방을 나가시겠습니까?",
            primaryButtonText: "나가기",
            secondaryButtonText: "취소") {
                withAnimation {
                    viewModel.exitRoom(at: viewModel.selectedRoomIndex ?? -1)
                }
                viewModel.showExitRoomDialog = false
            }

            .dialog(
                isPresented: $viewModel.showNetworkErrorDialog,
                title: "인터넷 연결 오류",
                content: "인터넷 연결을 확인해주세요.",
                primaryButtonText: "확인",
                onPrimaryButton: {}
            )
    }
}

#Preview {
    RoomListView()
}
