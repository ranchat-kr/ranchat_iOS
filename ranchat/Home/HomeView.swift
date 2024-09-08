//
//  HomeView.swift
//  ranchat
//
//  Created by 김견 on 9/9/24.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Ran-Chat")
                    .font(.dungGeunMo80)
                    
                Color.clear.frame(height: 30)
                
                MainButtonView(text: "START!") {
                    
                }
                
                Color.clear.frame(height: 10)
                
                MainButtonView(text: "CONTINUE!") {
                    
                }
                
            }
            .navigationBarItems(
                trailing: Button(action: {
                    print("setting_button")
                }, label: {
                    Image(systemName: "gearshape")
                        .tint(.white)
                })
            )
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Text("Copyright © KJI Corp. 2024 All Rights Reserved.")
                        .font(.dungGeunMo12)
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
