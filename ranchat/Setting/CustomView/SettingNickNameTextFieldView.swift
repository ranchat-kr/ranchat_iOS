//
//  SettingNickNameTextFieldView.swift
//  ranchat
//
//  Created by 김견 on 11/4/24.
//

import SwiftUI

struct SettingNickNameTextFieldView: View {
    @Binding var editNickName: String
    @Binding var isFouced: Bool
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        HStack {
            TextField("바꿀 닉네임을 입력해주세요.", text: $editNickName)
                .focused($isTextFieldFocused)
                .padding()
                .font(.dungGeunMo20)
                .foregroundColor(.white)
                .onChange(of: editNickName) { _, nickName in
                    if nickName.count > 10 {
                        let index = nickName.index(nickName.startIndex, offsetBy: 10)
                        editNickName = String(nickName[..<index])
                    }
                }
                .onChange(of: isFouced) { _, newValue in
                    isTextFieldFocused = newValue
                }
                .onChange(of: isTextFieldFocused) { _, newValue in
                    isFouced = newValue
                }
            
            Button {
                editNickName = ""
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.gray)
            }
            .padding(.trailing)
            .opacity(editNickName.isEmpty ? 0 : 1)
        }
        .background(
            RoundedRectangle(cornerRadius: 3)
                .strokeBorder(Color.white, lineWidth: 1)
                .background(RoundedRectangle(cornerRadius: 10).fill(.black))
        )
        .padding(.bottom, 20)
    }
}

#Preview {
    SettingNickNameTextFieldView(editNickName: .constant("닉네임"), isFouced: .constant(true))
}
