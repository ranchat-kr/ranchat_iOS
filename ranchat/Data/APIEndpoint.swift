//
//  APIEndpoint.swift
//  ranchat
//

import Foundation

enum APIEndpoint {
    private static var base: String { "https://\(DefaultData.shared.domain)" }

    static func users() throws -> URL {
        try makeURL("\(base)/v1/users")
    }

    static func user(id: String) throws -> URL {
        try makeURL("\(base)/v1/users/\(id)")
    }

    static func rooms() throws -> URL {
        try makeURL("\(base)/v1/rooms")
    }

    static func rooms(userId: String, page: Int, size: Int) throws -> URL {
        try makeURL("\(base)/v1/rooms?page=\(page)&size=\(size)&userId=\(userId)")
    }

    static func roomExists(userId: String) throws -> URL {
        try makeURL("\(base)/v1/rooms/exists-by-userId?userId=\(userId)")
    }

    static func roomDetail(userId: String, roomId: String) throws -> URL {
        try makeURL("\(base)/v1/rooms/\(roomId)?userId=\(userId)")
    }

    static func messages(roomId: String, page: Int, size: Int) throws -> URL {
        try makeURL("\(base)/v1/rooms/\(roomId)/messages?page=\(page)&size=\(size)")
    }

    static func reports() throws -> URL {
        try makeURL("\(base)/v1/reports")
    }

    static func notifications() throws -> URL {
        try makeURL("\(base)/v1/app-notifications")
    }

    private static func makeURL(_ path: String) throws -> URL {
        guard let url = URL(string: path) else {
            throw ApiHelperError.invalidURLError
        }
        return url
    }
}
