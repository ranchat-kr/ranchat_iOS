//
//  ToolbarBackButton.swift
//  ranchat
//
//  Created by 김견 on 10/17/24.
//

import SwiftUI

struct ToolbarBackButton: View {
    var action: () -> Void
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "chevron.left")
                .tint(.white)
        }
    }
}

#Preview {
    ToolbarBackButton(action: {})
}
