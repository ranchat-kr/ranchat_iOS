//
//  NicknameError.swift
//  ranchat
//

import Foundation

enum NicknameError {
    case empty
    case length
    case containsBlank
    case duplicate
    case specialCharacter
    case containsForbiddenCharacter
    case none
}
