//
//  CenterLoadingView.swift
//  ranchat
//
//  Created by 김견 on 10/8/24.
//

import SwiftUI

struct CenterLoadingView: View {
    var body: some View {
        Color.black.opacity(0.4)
            .ignoresSafeArea()

        ProgressView("Loading...")
            .progressViewStyle(CircularProgressViewStyle())
            .padding()
            .background(.gray)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(radius: 10)
    }
}

#Preview {
    CenterLoadingView()
}
