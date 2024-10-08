//
//  HomeView.swift
//  ranchat
//
//  Created by 김견 on 9/9/24.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(IdHelper.self) var idHelper
    @Environment(WebSocketHelper.self) var webSocketHelper
//    @Query private var user: User?
    @State private var isAnimating = false
    @State private var networkMotinor = NetworkMonitor()
    @Bindable var viewModel = HomeViewModel()
    
    
    let screenHeight = UIScreen.main.bounds.height
    
    var body: some View {
        NavigationStack {
            NavigationView {
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
                        
                        Color.clear.frame(height: 30)
                        
                        MainButtonView(text: "START!") {
                            
                        }
                        .opacity(isAnimating ? 1.0 : 0.0)
                        
                        
                        Color.clear.frame(height: 10)
                        

                        MainButtonView(text: "CONTINUE!") {
                            
                        }
                        
                        .opacity((viewModel.isRoomExist && isAnimating) ? 1.0 : 0.0)
                        
                    }
                    
                    
                    if viewModel.isLoading {
                        CenterLoadingView()
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .bottomBar) {
                        Text("Copyright © KJI Corp. 2024 All Rights Reserved.")
                            .font(.dungGeunMo12)
                            .opacity(isAnimating ? 1.0 : 0.0)
                            .animation(.easeInOut(duration: 1.0), value: isAnimating)
                    }
                    
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink(destination: {
                            SettingView()
                        }, label: {
                            Image(systemName: "gearshape")
                                .tint(.white)
                        })
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 1.0), value: isAnimating)
                    }
                }
            }
        }
        .onAppear {
            viewModel.setUser(idHelper: idHelper, webSocketHelper: webSocketHelper)
        }
        
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text("인터넷 연결 오류"),
                message: Text("인터넷 연결을 확인해주세요."),
                dismissButton: .default(Text("확인"))
            )
        }

        .onChange(of: networkMotinor.isConnected) { _, isConnected in
            if !isConnected {
                viewModel.showAlert = true
            }
        }
    }
}

#Preview {
    HomeView()
}
