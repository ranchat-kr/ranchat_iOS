//
//  DefaultResponse.swift
//  ranchat
//
//  Created by 김견 on 9/28/24.
//

import Foundation

struct DefaultResponse: Codable {
    var status: String
    var message: String
    var serverDateTime: String
    var data: Bool?
}
