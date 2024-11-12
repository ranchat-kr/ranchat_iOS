//
//  SettingView.swift
//  ranchat
//
//  Created by 김견 on 9/9/24.
//

import SwiftUI
import AlertToast

struct SettingView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(NetworkMonitor.self) var networkMonitor
    @State private var isTextFieldFocused: Bool = false
    @State private var viewModel = SettingViewModel()
    @AppStorage("permissionForNotification") var permissionForNotification = false
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                    Color.clear
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            isTextFieldFocused = false
                        }
                }
            
            VStack {
                if let name = viewModel.user?.name {
                    Text(" \(name) ")
                        .font(.dungGeunMo32)
                        .padding(.vertical, 20)
                }
                
                SettingBodyView(title: "알림 설정") {
                    SettingToggleView(isToggleOn: $viewModel.isToggleOn, onChange: viewModel.updateNotification)
                }
                
                Divider()
                    .frame(height: 0)
                    .background(.gray)
                    .padding(.vertical, 20)
            
                SettingBodyView(title: "닉네임 변경") {
                    SettingNickNameTextFieldView(editNickName: $viewModel.editNickName, isFouced: $isTextFieldFocused)
                    
                    Button {
                        if viewModel.isValidNickname() {
                            viewModel.showCheckNickNameDialog = true
                        }
                    } label: {
                        Text("변경하기")
                            .font(.dungGeunMo20)
                            .foregroundStyle(.red)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background {
                                Rectangle()
                                    .strokeBorder(.red, lineWidth: 1)
                            }
                    }
                }
                
                Spacer()
                
            }
            .padding(20)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    ToolbarButton(action: {
                        dismiss()
                    }, imageName: "chevron.backward")
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Setting")
                        .font(.dungGeunMo20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            
            if viewModel.isLoading {
                CenterLoadingView()
            }
        }
        .navigationBarBackButtonHidden()
        .onAppear {
            viewModel.setUser()
        }
        .onChange(of: networkMonitor.isConnected) { oldValue, newValue in
            if oldValue == false && newValue == true && !viewModel.isInitialized {  // 네트워크가 연결 되었을 때
                viewModel.setUser()
            }
        }
        .dialog(
            isPresented: $viewModel.showNetworkErrorDialog,
            title: "인터넷 연결 오류",
            content: "인터넷 연결을 확인해주세요.",
            primaryButtonText: "확인",
            onPrimaryButton: {}
        )
        .dialog(
            isPresented: $viewModel.showCheckNickNameDialog,
            title: "닉네임 변경",
            content: "닉네임을 '\(viewModel.editNickName)'\n(으)로 변경하시겠습니까?",
            primaryButtonText: "확인",
            secondaryButtonText: "취소",
            onPrimaryButton: viewModel.setNickname,
            onSecondaryButton: {}
        )
        .toast(isPresenting: $viewModel.showSuccessToast, alert: {
            AlertToast(type: .regular, title: "닉네임 변경이 완료되었습니다.", style: .style(titleFont: .dungGeunMo16))
        })
        .toast(isPresenting: $viewModel.showInValidToast, alert: {
            switch viewModel.nicknameError {
            case .Empty:
                return AlertToast(type: .error(.red), title: "닉네임을 입력해주세요.", style: .style(titleFont: .dungGeunMo16))
            case .Length:
                return AlertToast(type: .error(.red), title: "닉네임은 2자 이상 10자 이하로 입력해주세요.", style: .style(titleFont: .dungGeunMo16))
            case .ContainsBlank:
                return AlertToast(type: .error(.red), title: "닉네임에 공백이 포함되어 있습니다.", style: .style(titleFont: .dungGeunMo16))
            case .Duplicate:
                return AlertToast(type: .error(.red), title: "이미 사용중인 닉네임입니다.", style: .style(titleFont: .dungGeunMo16))
            case .SpecialCharacter:
                return AlertToast(type: .error(.red), title: "닉네임에 특수문자가 포함되어 있습니다.", style: .style(titleFont: .dungGeunMo16))
            case .ContainsForbiddenCharacter:
                return AlertToast(type: .error(.red), title: "닉네임에 금지된 단어가 포함되어 있습니다.", style: .style(titleFont: .dungGeunMo16))
            default:
                return AlertToast(type: .error(.red), title: "")
            }
        })
        .tint(.white)
    }
}

#Preview {
    SettingView()
}
