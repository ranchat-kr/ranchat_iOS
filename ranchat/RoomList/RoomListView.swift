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
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    RoomListView()
}
