//
//  UserData.swift
//  ranchat
//
//  Created by 김견 on 9/28/24.
//

import Foundation

struct UserData: Codable {
    var id: String
    var name: String
    
    func getName() -> String {
        name
    }
    
    mutating func setName(_ newName: String) {
        name = newName
    }
    
}
