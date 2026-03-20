//
//  SearchKeyword.swift
//  ranchat
//
//  Created by 김견 on 12/20/24.
//

import SwiftData
import Foundation

@Model
class SearchKeyword {
    @Attribute(.unique) var keyword: String
    var timestamp: Date = Date()

    init(keyword: String) {
        self.keyword = keyword
    }
}
