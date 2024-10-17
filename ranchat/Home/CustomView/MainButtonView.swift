//
//  MainButtonView.swift
//  ranchat
//
//  Created by 김견 on 9/9/24.
//

import SwiftUI

struct MainButtonView: View {
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Text(text)
                .font(.dungGeunMo30)
                .frame(width: 200, height: 50)
                .foregroundStyle(.white)
                .background {
                    Rectangle()
                        .foregroundColor(.clear)
                        .border(.white, width: 5)
                }
        }

    }
}

#Preview {
    MainButtonView(text: "START!", action: {})
}
