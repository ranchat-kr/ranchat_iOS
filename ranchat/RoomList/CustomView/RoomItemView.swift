//
//  RoomItemView.swift
//  ranchat
//
//  Created by 김견 on 10/17/24.
//

import SwiftUI

enum TimeFormatState {
    case today, yesterday, thisYear, anotherYear, none
}

struct DateData {
    var year: String
    var month: String
    var day: String
    var hour: String
    var minute: String
    var second: String
}

struct RoomItemView: View {
    var roomData: RoomData
    var action: () -> Void
    
    @State var timeFormatState: TimeFormatState = .none
    @State var isClicked: Bool = false
    @State var dateText: String = ""
    @State var dateFont: Font = .dungGeunMo12
    
    var body: some View {
        Button {
            action()
        } label: {
            VStack(alignment: .leading) {
                HStack {
                    Text(roomData.title)
                        .lineLimit(1)
                        .font(.dungGeunMo20)
                        .foregroundStyle(.pink)
                    
                    Spacer()
                    
                    Text(dateText)
                        .font(dateFont)
                        .foregroundStyle(.gray)
                }
                .padding(.bottom, 5)
                
                Text(roomData.latestMessage)
                    .lineLimit(1)
                    .font(.dungGeunMo12)
                    .foregroundStyle(.white)
            }
            
            .padding(.vertical, 10)
            .onAppear {
                dateText = parseToRoomDateFormat()
                dateFont = fontByTimeFormat()
            }
        }
        .buttonStyle(RoomItemViewButtonStyle())
    }
    
    func fontByTimeFormat() -> Font {
        switch timeFormatState {
        case .today, .thisYear:
            return .dungGeunMo12
        case .yesterday:
            return .dungGeunMo16
        case .anotherYear:
            return .dungGeunMo12
        case .none:
            return .dungGeunMo12
        }
    }
    
    func parseToRoomDateFormat() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        guard let messageDate = formatter.date(from: roomData.latestMessageAt) else { return ""
        }
        
        let currentDate = Date()
        let calendar = Calendar.current
        
        // 같은 해, 같은 달, 같은 날인지 확인
        if calendar.isDateInToday(messageDate) {
            formatter.dateFormat = "a h:mm"  // 오전/오후 h:mm 형식
            timeFormatState = .today
        } else if calendar.isDateInYesterday(messageDate) {
            timeFormatState = .yesterday
            return "어제"
        } else if calendar.component(.year, from: messageDate) == calendar.component(.year, from: currentDate) {
            formatter.dateFormat = "M월 d일"
            timeFormatState = .thisYear
        } else {
            formatter.dateFormat = "yyyy. MM. dd"
            timeFormatState = .anotherYear
        }
        
        formatter.locale = Locale(identifier: "ko_KR")  // 한국어 형식 설정
        return formatter.string(from: messageDate)
    }
    
}

#Preview {
    RoomItemView(roomData: RoomData(id: 1, title: "즐거운바다dasdasdqdqwdwqdqwdqwdqwdqwdqwdqwdqwqwdqwdwqdqwdwq", type: "type", latestMessage: "즐거운바다님이 입장하셨습니다.qwdqwdwqhdhwqdhqwuidhwqiudhisadasljdkladjkasjdl", latestMessageAt: "2024-02-15T21:01:28"), action: {}, dateText: "", dateFont: .dungGeunMo12)
}
