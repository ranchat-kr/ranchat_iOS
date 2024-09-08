//
//  Item.swift
//  ranchat
//
//  Created by 김견 on 9/8/24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
