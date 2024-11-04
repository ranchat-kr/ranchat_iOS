//
//  SettingBodyView.swift
//  ranchat
//
//  Created by 김견 on 11/4/24.
//

import SwiftUI

struct SettingBodyView<Content: View>: View {
    let content: Content
    @State var title: String
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack {
            Text(title)
                .font(.dungGeunMo16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(.green)
            
            content
        }
    }
}
