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
    var swipeAction: () -> Void

    @State var timeFormatState: TimeFormatState = .none
    @State var isClicked: Bool = false
    @State var dateText: String = ""
    @State var dateFont: Font = .dungGeunMo12

    private static let isoFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return f
    }()

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "a h:mm"
        f.locale = Locale(identifier: "ko_KR")
        return f
    }()

    private static let monthDayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "M월 d일"
        f.locale = Locale(identifier: "ko_KR")
        return f
    }()

    private static let fullDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy. MM. dd"
        f.locale = Locale(identifier: "ko_KR")
        return f
    }()

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
            .contentShape(Rectangle())
        }

        .buttonStyle(RoomItemViewButtonStyle())
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                swipeAction()
            } label: {
                Text("나가기")
                    .font(.dungGeunMo16)
                    .foregroundStyle(.white)
                    .padding()
            }
            .tint(.red)
        }
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
        guard let messageDate = Self.isoFormatter.date(from: roomData.latestMessageAt) else { return "" }

        let currentDate = Date()
        let calendar = Calendar.current

        if calendar.isDateInToday(messageDate) {
            timeFormatState = .today
            return Self.timeFormatter.string(from: messageDate)
        } else if calendar.isDateInYesterday(messageDate) {
            timeFormatState = .yesterday
            return "어제"
        } else if calendar.component(.year, from: messageDate) == calendar.component(.year, from: currentDate) {
            timeFormatState = .thisYear
            return Self.monthDayFormatter.string(from: messageDate)
        } else {
            timeFormatState = .anotherYear
            return Self.fullDateFormatter.string(from: messageDate)
        }
    }
}

#Preview {
    RoomItemView(roomData: RoomData(id: 1, title: "즐거운바다dasdasdqdqwdwqdqwdqwdqwdqwdqwdqwdqwqwdqwdwqdqwdwq", type: "type", latestMessage: "즐거운바다님이 입장하셨습니다.qwdqwdwqhdhwqdhqwuidhwqiudhisadasljdkladjkasjdl", latestMessageAt: "2024-02-15T21:01:28"), action: {}, swipeAction: {}, dateText: "", dateFont: .dungGeunMo12)
}
