//
//  NetworkError.swift
//  ranchat
//

enum ApiHelperError: Error {
    case invalidURLError
    case networkError(String)
    case responseDataError
    case nilError
}

enum Status: String {
    case success = "SUCCESS"
    case failure = "FAILURE"
}
