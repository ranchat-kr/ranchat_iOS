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

extension ApiHelperError {
    var dialogTitle: String {
        switch self {
        case .networkError:
            return "서버 오류"
        case .invalidURLError, .responseDataError, .nilError:
            return "오류"
        }
    }

    var dialogContent: String {
        switch self {
        case .networkError(let message) where !message.isEmpty:
            return message
        case .networkError:
            return "서버와 통신 중 오류가 발생했습니다."
        case .invalidURLError:
            return "잘못된 요청입니다."
        case .responseDataError:
            return "데이터를 불러오는 데 실패했습니다."
        case .nilError:
            return "필요한 정보를 찾을 수 없습니다."
        }
    }
}

enum Status: String {
    case success = "SUCCESS"
    case failure = "FAILURE"
}
