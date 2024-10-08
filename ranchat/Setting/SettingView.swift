//
//  SettingView.swift
//  ranchat
//
//  Created by 김견 on 9/9/24.
//

import SwiftUI

struct SettingView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var nickName: String
    @State var editNickName = ""
    
    var body: some View {
        NavigationView {
            VStack {
                Text(nickName)
                    .font(.dungGeunMo24)
                
                TextField("바꿀 닉네임을 입력해주세요.", text: $editNickName)
                    .padding()
                    .font(.dungGeunMo24)
                
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.backward")
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Setting")
                        .font(.dungGeunMo20)
                }
            }
        }
        .navigationBarBackButtonHidden()
        .tint(.white)
    }
}

#Preview {
    SettingView(nickName: .constant("닉네임"))
}
