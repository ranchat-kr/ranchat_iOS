//
//  SettingToggleView.swift
//  ranchat
//
//  Created by 김견 on 11/4/24.
//

import SwiftUI

struct SettingToggleView: View {
    @Binding var isToggleOn: Bool
    @AppStorage("permissionForNotification") var permissionForNotification = false
    var onChange: () -> Void
    
    var body: some View {
        ZStack {
            
            Toggle(isOn: $isToggleOn) {
                Text("알림")
                    .font(.dungGeunMo20)
                    .foregroundStyle(.white)
            }
            .padding()
            .toggleStyle(SwitchToggleStyle(tint: .red))
            .disabled(!permissionForNotification)
            .onChange(of: isToggleOn) {
                onChange()
                DefaultData.shared.isNotificationEnabled = isToggleOn
            }
            .background(
                RoundedRectangle(cornerRadius: 3)
                    .strokeBorder(.white, lineWidth: 1)
                    .background(RoundedRectangle(cornerRadius: 10).fill(.black))
            )
            .overlay {
                Color.black.opacity(permissionForNotification ? 0 : 0.8)
            }
        }
    }
}

#Preview {
    SettingToggleView(isToggleOn: .constant(true), onChange: {})
}
