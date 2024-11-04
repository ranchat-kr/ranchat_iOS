//
//  RoomListView.swift
//  ranchat
//
//  Created by 김견 on 10/17/24.
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
                })
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .swipeActions(edge: .trailing) {
                    Button(role: .cancel) {
                        
                        viewModel.selectedRoom = roomData
                        viewModel.selectedRoomIndex = index
                        viewModel.showExitRoomDialog = true
                    } label: {
                        Text("나가기")
                            .font(.dungGeunMo16)
                            .foregroundStyle(.white)
                            .padding()
                            .background(Color.red)
                    }
                }
                .onAppear {
                    if viewModel.roomItems.last?.id == roomData.id {
                        Task {
                            await viewModel.getRoomList()
                        }
                    }
                }
                
            }
            .animation(.snappy, value: viewModel.roomItems)
            .listStyle(.plain)
            
            .onAppear {
                viewModel.setHelper(webSocketHelper, idHelper)
                viewModel.setNetworkMonitor(networkMonitor)
                Task {
                    await viewModel.getRoomList()
                }
            }
            .onChange(of: networkMonitor.isConnected) { oldValue, newValue in
                if oldValue == false && newValue == true {  // 네트워크가 연결 되었을 때
                    Task {
                        if !viewModel.isInitialLized {
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
