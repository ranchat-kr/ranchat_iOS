//
//  ToolbarBackButton.swift
//  ranchat
//
//  Created by 김견 on 10/17/24.
//

import SwiftUI

struct ToolbarButton: View {
    var action: () -> Void
    var imageName: String
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: imageName)
                .tint(.white)
        }
    }
}

#Preview {
    ToolbarButton(action: {}, imageName: "")
}
