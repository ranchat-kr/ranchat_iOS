//
//  DefaultResponse.swift
//  ranchat
//
//  Created by 김견 on 9/28/24.
//

import Foundation


/// data가 Int 또는 Bool이 올 수 있기에 enum으로 타입 구분
enum DataType: Codable {
    case intValue(Int)
    case boolValue(Bool)
    case userDataValue(UserData)
    
    // JSON 디코딩
    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intValue = try? container.decode(Int.self) {
            self = .intValue(intValue)
        } else if let boolValue = try? container.decode(Bool.self) {
            self = .boolValue(boolValue)
        } else if let userDataValue = try? container.decode(UserData.self) {
            self = .userDataValue(userDataValue)
        } else {
            throw DecodingError.typeMismatch(DataType.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected Int or Bool or UserData"))
        }
    }
    
    // JSON 인코딩
    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .intValue(let intValue):
            try container.encode(intValue)
        case .boolValue(let boolValue):
            try container.encode(boolValue)
        case .userDataValue(let userDataValue):
            try container.encode(userDataValue)
        }
    }
}

struct DefaultResponse: Codable {
    var status: String
    var message: String
    var serverDateTime: String
    var data: DataType?
}
