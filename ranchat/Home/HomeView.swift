//
//  HomeView.swift
//  ranchat
//
//  Created by 김견 on 9/9/24.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(IdHelper.self) var idHelper
    @Environment(WebSocketHelper.self) var webSocketHelper
    @Environment(NetworkMonitor.self) var networkMonitor
    //    @Query private var user: User?
    @State private var isAnimating = false
    @State var viewModel = HomeViewModel()
    
    
    let screenHeight = UIScreen.main.bounds.height
    
    var body: some View {
        NavigationStack {
            
            ZStack {
                VStack {
                    Text("Ran-Talk")
                        .font(.dungGeunMo80)
                        .offset(y: isAnimating ? 0 : -screenHeight / 2)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 1.0)) {
                                isAnimating = true
                            }
                        }
                        .padding(.bottom, 30)
                    
                    MainButtonView(text: "START!") {
                        viewModel.requestMatching()
                    }
                    .opacity(isAnimating ? 1.0 : 0.0)
                    
                    ZStack {
                        
                            MainButtonView(text: "CONTINUE!") {
                                viewModel.navigateToRoomList()
                                    
                            }
                            .opacity(isAnimating ? 1.0 : 0.0)

                        
                        
                        Color.black.frame(height: viewModel.isRoomExist ? 0 : 50)
                    }
                }
                
                
                if viewModel.isLoading {
                    CenterLoadingView()
                }
                
                if viewModel.isMatching && !webSocketHelper.isMatchSuccess {
                    MatchingLoadingView()
                } 
            }
//            .animation(.easeInOut, value: viewModel.isMatching)
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Text("Copyright © KJI Corp. 2024 All Rights Reserved.")
                        .font(.dungGeunMo12)
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 1.0), value: isAnimating)
                }
                
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.navigateToSetting()
                    } label: {
                        Image(systemName: "gearshape")
                            .tint(.white)
                    }
                }
            }
            .navigationDestination(isPresented: $viewModel.goToSetting, destination: {
                SettingView()
            })
            .navigationDestination(isPresented: $viewModel.goToChat, destination: {
                ChattingView()
                    .onDisappear {
                        Task {
                            await viewModel.checkRoomExist()
                        }
                    }
            })
            .navigationDestination(isPresented: $viewModel.goToRoomList, destination: {
                RoomListView()
                    .onDisappear {
                        Task {
                            await viewModel.checkRoomExist()
                        }
                    }
            })
        }
        
        .onAppear {
            viewModel.setHelper(webSocketHelper, idHelper)
            viewModel.setNetworkMonitor(networkMonitor)
            //viewModel.setUser()
        }
        
        .onChange(of: networkMonitor.isConnected) { oldValue, newValue in
            if oldValue == false && newValue == true && !viewModel.isInitialized {  // 네트워크가 연결 되었을 때
                viewModel.setUser()
            }
        }
        
        .onChange(of: webSocketHelper.isMatchSuccess) { _, newValue in
            if newValue {
                viewModel.successMatching()
            }
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
    HomeView()
}
