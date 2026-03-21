//
//  HomeView.swift
//  ranchat
//

import SwiftUI

struct HomeView: View {
    @Environment(IdHelper.self) var idHelper
    @Environment(WebSocketHelper.self) var webSocketHelper
    @Environment(NetworkMonitor.self) var networkMonitor
    @State private var isAnimating = false
    @State var viewModel = HomeViewModel()

    var body: some View {
        GeometryReader { geometry in
        NavigationStack {

            ZStack {
                VStack {
                    Text("Ran-Talk")
                        .font(.dungGeunMo80)
                        .offset(y: isAnimating ? 0 : -geometry.size.height / 2)
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

                    MainButtonView(text: "CONTINUE!") {
                        viewModel.navigateToRoomList()
                    }
                    .opacity(isAnimating && viewModel.isRoomExist ? 1.0 : 0.0)
                    .disabled(!viewModel.isRoomExist)
                }

                if viewModel.isLoading {
                    CenterLoadingView()
                }

                if viewModel.isMatching && !viewModel.isMatchSuccess {
                    MatchingLoadingView()
                }
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Text("Copyright © KJI Corp. 2024 All Rights Reserved.")
                        .font(.dungGeunMo12)
                        .frame(maxWidth: .infinity)
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
        } // GeometryReader

        .onAppear {
            viewModel.setup(webSocketService: webSocketHelper, idHelper: idHelper, networkMonitor: networkMonitor)
            viewModel.setUser()
        }
        .onDisappear {
            isAnimating = false
        }

        .onChange(of: networkMonitor.isConnected) { oldValue, newValue in
            if oldValue == false && newValue == true && !viewModel.isInitialized {
                viewModel.setUser()
            }
        }

        .onChange(of: viewModel.isMatchSuccess) { _, newValue in
            if newValue {
                viewModel.successMatching()
            }
        }
        .dialog(
            isPresented: $viewModel.showNetworkErrorDialog,
            title: viewModel.networkErrorTitle,
            content: viewModel.networkErrorContent,
            primaryButtonText: "확인",
            onPrimaryButton: {}
            )
    }
}

#Preview {
    HomeView()
}
