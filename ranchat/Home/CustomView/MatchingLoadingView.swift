//
//  MatchingLoadingView.swift
//  ranchat
//
//  Created by 김견 on 10/9/24.
//

import SwiftUI

struct MatchingLoadingView: View {
    @State private var currentStep = 0
    private let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Color.black.opacity(0.4)
            .edgesIgnoringSafeArea(.all)
        
        
        VStack(spacing: 20) {
            Text("매칭 중")
                .font(.dungGeunMo32)
                .foregroundStyle(.black)
                .padding(.top, 20)
            
            HStack(spacing: 8) {
                ForEach(0..<4) { index in
                    buildStep(active: currentStep % 5 == index)
                }
            }
            .padding(.bottom, 20)
        }
        .frame(maxWidth: UIScreen.main.bounds.width - 60)
        .frame(height: 120)
        .background(.white)
        .cornerRadius(10)
        .padding()
        .onReceive(timer) { _ in
            currentStep = (currentStep + 1) % 5
        }
    }
    
    private func buildStep(active: Bool) -> some View {
        Rectangle()
            .fill(active ? .black : .gray)
            .frame(width: 20, height: 20)
    }
}

#Preview {
    MatchingLoadingView()
}
