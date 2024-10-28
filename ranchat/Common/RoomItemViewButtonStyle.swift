//
//  RoomItemViewButtonStyle.swift
//  ranchat
//
//  Created by 김견 on 10/28/24.
//

import SwiftUI

struct RoomItemViewButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(configuration.isPressed ? .gray.opacity(0.3) : .clear)
            .foregroundColor(.white)
    }
}
