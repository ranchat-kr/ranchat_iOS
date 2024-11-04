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
    @FocusState private var isTextFieldFocused: Bool
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
                
                Spacer()
                
                Toggle(isOn: $viewModel.isToggleOn) {
                    Text("알림")
                        .font(.dungGeunMo20)
                        .foregroundStyle(permissionForNotification ? .white : .gray)
                }
                .padding()
                .toggleStyle(SwitchToggleStyle(tint: .red))
                .disabled(!permissionForNotification)
                .onChange(of: viewModel.isToggleOn) {
                    viewModel.updateNotification()
                    DefaultData.shared.isNotificationEnabled = viewModel.isToggleOn
                }
                
                Divider()
                    .padding(.vertical, 10)
                
                if let name = viewModel.user?.name {
                    Text(" \(name) ")
                        .font(.dungGeunMo24)
                        .padding(.bottom, 20)
                }
                
                
                HStack {
                    TextField("바꿀 닉네임을 입력해주세요.", text: $viewModel.editNickName)
                        .focused($isTextFieldFocused)
                        .padding()
                        .font(.dungGeunMo20)
                        .foregroundColor(.white)
                    
                    Button {
                        viewModel.editNickName = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.gray)
                    }
                    .padding(.trailing)
                    .opacity(viewModel.editNickName.isEmpty ? 0 : 1)
                }
                .background(
                    RoundedRectangle(cornerRadius: 3)
                        .strokeBorder(Color.white, lineWidth: 1)
                        .background(RoundedRectangle(cornerRadius: 10).fill(.black))
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                
                Button {
                    if viewModel.isValidNickname() {
                        viewModel.showCheckNickNameAlert = true
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
                
                Spacer()
                
            }
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
            viewModel.getPermissionForNotification()
            viewModel.setUser()
        }
        .onChange(of: networkMonitor.isConnected) { oldValue, newValue in
            if oldValue == false && newValue == true {  // 네트워크가 연결 되었을 때
                viewModel.setUser()
            }
        }
        .dialog(
            isPresented: $viewModel.showNetworkErrorAlert,
            title: "인터넷 연결 오류",
            content: "인터넷 연결을 확인해주세요.",
            primaryButtonText: "확인",
            onPrimaryButton: {}
        )
        .dialog(
            isPresented: $viewModel.showCheckNickNameAlert,
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
