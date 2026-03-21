//
//  NetworkClient.swift
//  ranchat
//

import Foundation
import Alamofire

protocol NetworkClient {
    func request<T: Decodable>(url: URL, method: HTTPMethod, params: [String: Any]?) async throws -> T
}

final class AlamofireNetworkClient: NetworkClient {
    private let headers: HTTPHeaders = ["Content-Type": "application/json", "Accept": "application/json"]

    func request<T: Decodable>(url: URL, method: HTTPMethod, params: [String: Any]?) async throws -> T {
        try await AF.request(
            url,
            method: method,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: headers
        )
        .validate(statusCode: 200..<300)
        .serializingDecodable(T.self)
        .value
    }
}
