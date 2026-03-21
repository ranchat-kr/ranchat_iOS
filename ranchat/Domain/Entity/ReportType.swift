//
//  ReportType.swift
//  ranchat
//

import Foundation

enum ReportType: String {
    case spam = "SPAM"
    case harassment = "HARASSMENT"
    case advertisement = "ADVERTISEMENT"
    case misinformation = "MISINFORMATION"
    case copyrightInfringement = "COPYRIGHT_INFRINGEMENT"
    case etc = "ETC"
    case unknown = ""

    init(reason: String?) {
        switch reason {
        case "스팸": self = .spam
        case "욕설 및 비방": self = .harassment
        case "광고": self = .advertisement
        case "허위 정보": self = .misinformation
        case "저작권 침해": self = .copyrightInfringement
        case "기타": self = .etc
        default: self = .unknown
        }
    }
}
