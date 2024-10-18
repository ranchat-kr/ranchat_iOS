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
    @State private var isScrolledToBottom = false
    
    var body: some View {
        ZStack {
            List(Array(viewModel.roomItems.enumerated()), id: \.element.id) { index, roomData in
                // 채팅방 리스트
                //                ForEach(Array(viewModel.roomItems.enumerated()), id: \.element.id) { index, roomData in
                RoomItemView(roomData: roomData)
                    .listRowInsets(EdgeInsets())
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            withAnimation {
                                viewModel.exitRoom(at: index)
                            }
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
                //                }
            }
            .listStyle(.plain)
            .onAppear {
                viewModel.setHelper(webSocketHelper)
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
        }
    }
}

#Preview {
    RoomListView()
}
