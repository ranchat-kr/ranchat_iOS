//
//  EmptyRoomListView.swift
//  ranchat
//

import SwiftUI

struct EmptyRoomListView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("채팅방이 없습니다.")
                .font(.dungGeunMo20)
                .foregroundStyle(.gray)

            Text("홈으로 돌아가 매칭을 시작해보세요!")
                .font(.dungGeunMo12)
                .foregroundStyle(.gray.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    EmptyRoomListView()
        .preferredColorScheme(.dark)
}
