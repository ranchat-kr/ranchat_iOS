//
//  ChatInputView.swift
//  ranchat
//
//  Created by 김견 on 10/9/24.
//

import SwiftUI

struct ChatInputView: View {
    @Binding var inputText: String
    @Binding var chattingList: [MessageData]
    @FocusState private var isTextFieldFocused: Bool
    var onSend: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "chevron.forward")
                
            
            TextField("입력하세요.", text: $inputText)
                .focused($isTextFieldFocused)
                .font(.dungGeunMo16)
                .textFieldStyle(.plain)
                .padding(.horizontal, 10)
                
            
            Button {
                onSend()
            } label: {
                Text("보내기")
                    .font(.dungGeunMo16)
                    .frame(width: 80, height: 40)
                    .background(
                        Rectangle()
                            .stroke(.yellow, lineWidth: 2)
                    )
                    .foregroundStyle(.yellow)
                    
            }
            
        }
        .padding()
        .onAppear {
            isTextFieldFocused = true
        }
    }
}

#Preview {
    ChatInputView(inputText: .constant(""), chattingList: .constant([]), onSend: {})
}
