//
//  ReportDialogView.swift
//  ranchat
//
//  Created by 김견 on 10/9/24.
//

import SwiftUI
import AlertToast

struct ReportDialogView: View {
    @Binding var isPresented: Bool
    @Binding var selectedReason: String?
    @Binding var reportText: String
    @Binding var isFocused: Bool
    @State var showWarningToSelectReasonToast: Bool = false
    @State var showWarningToReportContentToast: Bool = false
    @State var showReasonPicker: Bool = false
    @FocusState var isTextFieldFocused: Bool
    var reportReasons = [
        "사유를 선택해주세요.", "스팸", "욕설 및 비방", "광고", "허위 정보", "저작권 침해", "기타"
    ]
    var onReport: () async -> Void
    
    var body: some View {
        Color.black.opacity(0.4)
            .edgesIgnoringSafeArea(.all)
            .onTapGesture {
                optionClear()
            }
        
        ZStack {
            VStack (alignment: .leading) {
                Text("신고")
                    .font(.dungGeunMo32)
                    .foregroundStyle(.black)
                    .padding(.bottom, 30)
                
                Button {
                    showReasonPicker = true
                } label: {
                    HStack {
                        Text("신고 사유 선택")
                            .font(.dungGeunMo16)
                            .foregroundStyle(.black)
                        
                        Text((selectedReason == reportReasons[0] ? "" : selectedReason) ?? "")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .font(.dungGeunMo16)
                            .foregroundStyle(.blue)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.up.chevron.down")
                            .foregroundStyle(.black)
                            .padding(.trailing, 10)
                        
                    }
                    .padding(.bottom, 30)
                }
                
                ZStack(alignment: .leading) {
                    
                    if reportText.isEmpty {
                        Text("신고 내용을 입력하세요.")
                            .foregroundColor(.gray) // 원하는 색상으로 변경
                            .padding(.horizontal, 20)
                            .font(.dungGeunMo20)
                            .frame(maxHeight: .infinity, alignment: .center)
                    }
                    
                    TextField("", text: $reportText, axis: .vertical)
                        .focused($isTextFieldFocused)
                        .lineLimit(3)
                        .padding(.horizontal, 20)
                        .font(.dungGeunMo24)
                        .foregroundStyle(.black)
                        .tint(.gray)
                        .background(.clear)
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.black, lineWidth: 1)
                                .padding(.vertical, -10)
                        }
                        .onAppear {
                            isTextFieldFocused = isFocused
                        }
                        .onChange(of: isTextFieldFocused) { _, newValue in
                            isFocused = newValue
                        }
                        .onChange(of: isFocused) { _, newValue in
                            isTextFieldFocused = newValue
                        }
                    
                }
                .padding(.bottom, 30)
                .frame(maxHeight: 100)
                
                HStack {
                    Spacer()
                    
                    Button {
                        optionClear()
                    } label: {
                        Text("취소")
                            .font(.dungGeunMo16)
                            .padding(.trailing, 12)
                    }
                    
                    Button {
                        if selectedReason == nil || selectedReason == reportReasons.first {
                            showWarningToSelectReasonToast = true
                        } else if reportText.isEmpty {
                            showWarningToReportContentToast = true
                        } else {
                            Task {
                                await onReport()
                                optionClear()
                            }
                        }
                    } label: {
                        Text("신고")
                            .font(.dungGeunMo16)
                            .padding(.horizontal, 12)
                    }
                }
            }
            .frame(maxWidth: 300)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .backgroundStyle(.white)
            )
            .toast(isPresenting: $showWarningToSelectReasonToast, alert: {
                AlertToast(type: .regular, title: "신고 사유를 선택해주세요.", style: .style(titleFont: .dungGeunMo16))
            })
            .toast(isPresenting: $showWarningToReportContentToast, alert: {
                AlertToast(type: .regular, title: "신고 내용을 입력해주세요.", style: .style(titleFont: .dungGeunMo16))
            })
            
            if showReasonPicker {
                VStack {
                    HStack {
                        Spacer()
                        
                        Button {
                            showReasonPicker = false
                        } label: {
                            Text("선택")
                                .font(.dungGeunMo20)
                                .foregroundStyle(.blue)
                                .padding(.trailing, 12)
                                .padding(.top, 12)
                        }
                    }
                    
                    Picker("신고 사유 선택", selection: $selectedReason) {
                        ForEach(reportReasons, id: \.self) { reason in
                            Text(reason)
                                .font(.dungGeunMo20)
                                .foregroundStyle(.blue)
                                .tag(reason as String?)
                            
                        }
                    }
                    .tint(.black)
                    .pickerStyle(.wheel)
                }
                .frame(maxWidth: 300)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.gray, lineWidth: 3)
                        .background(.white)
                )
            }
        }
    }
    
    private func optionClear() {
        selectedReason = nil
        reportText = ""
        isPresented = false
        isFocused = false
    }
}

#Preview {
    ReportDialogView(isPresented: .constant(true), selectedReason: .constant("욕설 및 비방"), reportText: .constant(""), isFocused: .constant(true), onReport: {})
}
