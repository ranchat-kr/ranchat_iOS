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
    
    @State var viewModel = RoomListViewModel()
    
    var body: some View {
        ZStack {
            List(Array(viewModel.roomItems.enumerated()), id: \.element.id) { index, roomData in
                
                RoomItemView(roomData: roomData, action: {
                    viewModel.enterRoom(at: index)
                })
                    .listRowInsets(EdgeInsets())
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
            .listStyle(.plain)
            .onAppear {
                viewModel.setHelper(webSocketHelper, idHelper)
                Task {
                    await viewModel.getRoomList()
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
            
            if viewModel.showExitRoomDialog {
                ExitRoomDialogView(
                    isPresented: $viewModel.showExitRoomDialog,
                    title: viewModel.selectedRoom?.title ?? "",
                    onConfirm: {
                        withAnimation {
                            viewModel.exitRoom(at: viewModel.selectedRoomIndex ?? -1)
                        }
                        viewModel.showExitRoomDialog = false
                    }
                )
            }
        }
        .navigationDestination(isPresented: $viewModel.goToChat, destination: {
            ChattingView(roomListViewModel: viewModel)
        })
    }
}

#Preview {
    RoomListView()
}
