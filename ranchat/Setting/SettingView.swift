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
    @State private var viewModel = SettingViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    
                    if let name = viewModel.user?.name {
                        Text(name)
                            .font(.dungGeunMo24)
                            .padding(.bottom, 20)
                    }
                    
                    
                    HStack {
                        TextField("바꿀 닉네임을 입력해주세요.", text: $viewModel.editNickName)
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
                    
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.backward")
                        }
                    }
                    
                    ToolbarItem(placement: .principal) {
                        Text("Setting")
                            .font(.dungGeunMo20)
                    }
                }
                
                if viewModel.isLoading {
                    CenterLoadingView()
                }
            }
        }
        .onAppear {
            viewModel.setUser()
        }
        .alert(isPresented: $viewModel.showNetworkErrorAlert) {
            Alert(
                title: Text("인터넷 연결 오류")
                    .font(.dungGeunMo24),
                message: Text("인터넷 연결을 확인해주세요.")
                    .font(.dungGeunMo16),
                dismissButton: .default(Text("확인"))
            )
        }
        .alert(isPresented: $viewModel.showCheckNickNameAlert) {
            Alert(
                title: Text("닉네임 변경")
                    .font(.dungGeunMo24),
                message: Text("닉네임을 \(viewModel.editNickName)(으)로 변경하시겠습니까?")
                    .font(.dungGeunMo16),
                primaryButton: .destructive(Text("확인")) {
                    viewModel.setNickname()
                },
                secondaryButton: .cancel()
            )
        }
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
        .navigationBarBackButtonHidden()
        .tint(.white)
    }
}

#Preview {
    SettingView()
}
