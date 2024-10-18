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
            ScrollView {
                VStack {
                    // 채팅방 리스트
                    ForEach(Array(viewModel.roomItems.enumerated()), id: \.element.id) { index, roomData in
                        RoomItemView(roomData: roomData)
                        
                        if index < viewModel.roomItems.count - 1 {
                            Rectangle()
                                .background(.gray)
                                .frame(height: 1)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal)
                        }
                    }
                }
                .padding(.top, -40)
                .background(
                    GeometryReader { proxy in
                        Color.clear
                            .onChange(of: proxy.frame(in: .global).maxY) { _ in
                                checkIfScrolledToBottom(proxy: proxy)
                            }
                    }
                )
            }
            .onAppear {
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
            
            if viewModel.isLoading {
                CenterLoadingView()
            }
        }
    }
    
    private func checkIfScrolledToBottom(proxy: GeometryProxy) {
        let contentHeight = proxy.size.height
        let scrollViewHeight = UIScreen.main.bounds.height
        let scrollOffset = abs(proxy.frame(in: .global).minY)

        print("contentHeight: \(contentHeight), scrollViewHeight: \(scrollViewHeight), scrollOffset: \(scrollOffset)")
        // Adjust the condition based on your requirement.
        if  (scrollViewHeight - 50)...scrollViewHeight ~= scrollOffset + contentHeight {
            // ScrollView가 맨 아래에 도달했을 때 호출될 함수
            Task {
                await viewModel.getRoomList()
            }
        }
    }
}

#Preview {
    RoomListView()
}
