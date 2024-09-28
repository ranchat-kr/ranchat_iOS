//
//  HomeView.swift
//  ranchat
//
//  Created by 김견 on 9/9/24.
//

import SwiftUI

struct HomeView: View {
    @State private var isAnimating = false
    @State var nickName = "닉네임"
    @Bindable var viewModel = HomeViewModel()
    
    let screenHeight = UIScreen.main.bounds.height
    
    var body: some View {
        NavigationStack {
            NavigationView {
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
                        Task {
                            try await ApiHelper.getRooms()
                        }
                    }
                    .opacity(isAnimating ? 1.0 : 0.0)
                    
                    
                    Color.clear.frame(height: 10)
                    
                    MainButtonView(text: "CONTINUE!") {
                        
                    }
                    .opacity(isAnimating ? 1.0 : 0.0)
                    
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
                            SettingView(nickName: $nickName)
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
    }
}

#Preview {
    HomeView()
}
