//
//  DialogViewModifier.swift
//  ranchat
//
//  Created by 김견 on 10/31/24.
//

import SwiftUI

public struct DialogViewModifier: ViewModifier {
    @Binding var isPresented: Bool
    
    var title: String
    var content: String?
    var primaryButtonText: String
    var secondaryButtonText: String?
    var onPrimaryButton: () -> Void
    var onSecondaryButton: (() -> Void)?
    
    public func body(content: Content) -> some View {
        content
            .overlay(
                Group {
                    if isPresented {
                        VStack(alignment: .leading) {
                            Text(title)
                                .font(.dungGeunMo32)
                                .foregroundStyle(.black)
                                .padding(.bottom, 30)
                            
                            Text(self.content ?? "")
                                .font(.dungGeunMo20)
                                .foregroundStyle(.black)
                                .padding(.bottom, 30)
                            
                            HStack {
                                Spacer()
                                
                                // Secondary Button
                                if let secondaryText = secondaryButtonText {
                                    Button {
                                        onSecondaryButton?()
                                        isPresented = false
                                    } label: {
                                        Text(secondaryText)
                                            .font(.dungGeunMo16)
                                            .foregroundStyle(.blue)
                                            .padding(.trailing, 12)
                                    }
                                }
                                
                                // Primary Button
                                Button {
                                    onPrimaryButton()
                                    isPresented = false
                                } label: {
                                    Text(primaryButtonText)
                                        .font(.dungGeunMo16)
                                        .foregroundStyle(.blue)
                                        .padding(.horizontal, 12)
                                }
                            }
                        }
                        .frame(maxWidth: 300)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .foregroundColor(.white)
                        )
                    }
                }
            )
    }
}

public extension View {
    func dialog(isPresented: Binding<Bool>, title: String, content: String? = nil, primaryButtonText: String, secondaryButtonText: String? = nil, onPrimaryButton: @escaping () -> Void, onSecondaryButton: (() -> Void)? = nil) -> some View {
        modifier(
            DialogViewModifier(isPresented: isPresented, title: title, content: content, primaryButtonText: primaryButtonText, secondaryButtonText: secondaryButtonText, onPrimaryButton: onPrimaryButton, onSecondaryButton: onSecondaryButton)
        )
    }
}
