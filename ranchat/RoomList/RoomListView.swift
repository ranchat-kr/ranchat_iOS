//
//  RoomListView.swift
//  ranchat
//
//  Created by 김견 on 10/17/24.
//

import SwiftUI

struct RoomListView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(IdHelper.self) var idHelper
    @Environment(WebSocketHelper.self) var webSocketHelper
    @State var viewModel = RoomListViewModel()
    
    var body: some View {
        ScrollView {
            GeometryReader { geometry in
                
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Continue")
                    .font(.dungGeunMo24)
            }
            ToolbarItem(placement: .topBarLeading) {
                ToolbarButton(action: {
                    dismiss()
                }, imageName: "chevron.backward")
            }
        }
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    RoomListView()
}
