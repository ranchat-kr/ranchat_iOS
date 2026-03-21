//
//  RoomItemView.swift
//  ranchat
//

import SwiftUI

struct RoomItemView: View {
    var roomData: Room
    var action: () -> Void
    var swipeAction: () -> Void

    @State var dateText: String = ""
    @State var dateFont: Font = .dungGeunMo12

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
                (dateText, dateFont) = formatDate(roomData.latestMessageAt)
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

    private func formatDate(_ date: Date) -> (String, Font) {
        let calendar = Calendar.current
        let currentDate = Date()

        if calendar.isDateInToday(date) {
            return (Self.timeFormatter.string(from: date), .dungGeunMo12)
        } else if calendar.isDateInYesterday(date) {
            return ("어제", .dungGeunMo16)
        } else if calendar.component(.year, from: date) == calendar.component(.year, from: currentDate) {
            return (Self.monthDayFormatter.string(from: date), .dungGeunMo12)
        } else {
            return (Self.fullDateFormatter.string(from: date), .dungGeunMo12)
        }
    }
}

#Preview {
    RoomItemView(
        roomData: Room(id: 1, title: "즐거운바다", type: .normal, latestMessage: "안녕하세요", latestMessageAt: Date()),
        action: {},
        swipeAction: {}
    )
}
