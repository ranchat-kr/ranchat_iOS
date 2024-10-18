//
//  ExitRoomDialogView.swift
//  ranchat
//
//  Created by 김견 on 10/18/24.
//

import SwiftUI

struct ExitRoomDialogView: View {
    @Binding var isPresented: Bool
    
    var title: String
    var onConfirm: () -> Void
    
    var body: some View {
        Color.black.opacity(0.4)
            .edgesIgnoringSafeArea(.all)
            .onTapGesture {
                isPresented = false
            }
        
        VStack (alignment: .leading) {
            Text("방 나가기")
                .font(.dungGeunMo32)
                .foregroundStyle(.black)
                .padding(.bottom, 30)
            
            Text("'\(title)'\n 채팅방을 나가시겠습니까?")
                .font(.dungGeunMo20)
                .foregroundStyle(.black)
            .padding(.bottom, 30)
            
            
            HStack {
                Spacer()
                
                Button {
                    isPresented = false
                } label: {
                    Text("취소")
                        .font(.dungGeunMo16)
                        .padding(.trailing, 12)
                }
                
                Button {
                    onConfirm()
                } label: {
                    Text("확인")
                        .font(.dungGeunMo16)
                        .padding(.horizontal, 12)
                }
            }
        }
        .frame(maxWidth: 300)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .backgroundStyle(.white)
        )
    }
}

#Preview {
    ExitRoomDialogView(isPresented: .constant(true as Bool), title: "ㅇㅇㅇ", onConfirm: {})
}
