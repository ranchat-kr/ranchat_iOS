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
    @Binding var isFocused: Bool
    @FocusState private var isTextFieldFocused: Bool
    var onSend: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "chevron.forward")
                
            
            TextField("입력하세요.", text: $inputText, axis: .vertical)
                .lineLimit(3)
                .focused($isTextFieldFocused)
                .font(.dungGeunMo16)
                .textFieldStyle(.plain)
                .padding(.horizontal, 10)
                .onAppear {
                    isTextFieldFocused = isFocused
                }
                .onChange(of: isTextFieldFocused) { _, newValue in
                    isFocused = newValue
                }
                .onChange(of: isFocused) { _, newValue in
                    isTextFieldFocused = newValue
                }

                
            
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
    ChatInputView(inputText: .constant(""), chattingList: .constant([]), isFocused: .constant(true), onSend: {})
}
