//
//  ApiResponseDTO.swift
//  ranchat
//

import Foundation

struct ApiResponseDTO<T: Codable>: Codable {
    let status: String
    let message: String
    let serverDateTime: String
    let data: T?
}
