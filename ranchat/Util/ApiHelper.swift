//
//  ApiHelper.swift
//  ranchat
//
//  Created by 김견 on 9/14/24.
//

import Foundation
import Alamofire
import SwiftUI

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

class ApiHelper {
    static let shared = ApiHelper()
    var idHelper: IdHelper?
    
    let headers: HTTPHeaders = ["Content-Type": "application/json", "Accept": "application/json"]
//    let roomId: String = "1"
//    let userId: String = "0190964c-ee3a-7e81-a1f8-231b5d97c2a1"
    
    func setIdHelper(idHelper: IdHelper) {
        self.idHelper = idHelper
    }
    
    //MARK: - Report
    /// 유저 신고하기
    func reportUser(reportedUserId: String, reportReason: String, reportType: String) async throws {
        
        guard let userId = idHelper?.getUserId() else {
            throw ApiHelperError.nilError
        }
        
        guard let roomId = idHelper?.getRoomId() else {
            throw ApiHelperError.nilError
        }
        
        guard let url = URL(string: "https://\(DefaultData.domain)/v1/reports") else {
            throw ApiHelperError.invalidURLError
        }
        
        let param: [String: Any] = [
            "roomId": roomId,
            "reporterId": userId,
            "reportedUserId": reportedUserId,
            "reportType": reportType,
            "reportReason": reportReason,
        ]
        
        do {
            let response = try await AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: headers)
                .validate(statusCode: 200..<300)
                .serializingDecodable(DefaultResponse.self)
                .value
            
            if response.status == Status.success.rawValue {
                print("DEBUG: Success to report user: \(response)")
            } else {
                print("DEBUG: Failed to report user with error: \(response.message)")
                throw ApiHelperError.networkError(response.message)
            }
            
        } catch {
            print("DEBUG: Failed to report user with error: \(error.localizedDescription)")
            throw ApiHelperError.networkError(error.localizedDescription)
        }
    }
    
    //MARK: - ChatRoom
    /// CONTINUE! 화면에서 나오는 방 리스트 호출
    func getRooms(page: Int = 0, size: Int = 10) async throws -> RoomDataList {
        guard let userId = idHelper?.getUserId() else {
            throw ApiHelperError.nilError
        }
        
        guard let url = URL(string: "https://\(DefaultData.domain)/v1/rooms?page=\(page)&size=\(size)&userId=\(userId)") else {
            throw ApiHelperError.invalidURLError
        }
                
        do {
            let response = try await AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headers)
                .validate(statusCode: 200..<300)
                .serializingDecodable(RoomDataList.self)
                .value
            
            if response.status == Status.success.rawValue {
                // print("DEBUG: Success to get rooms: \(response)")
                return response
            } else {
                print("DEBUG: Failed to get rooms with error: \(response.message)")
                throw ApiHelperError.networkError(response.message)
            }
        } catch {
            print("DEBUG: Failed to get rooms with error: \(error.localizedDescription)")
            throw ApiHelperError.networkError(error.localizedDescription)
        }
    }
    
    /// HOME화면에서 CONTINUE! 버튼의 Visible유무를 판단하기 위한 방 존재 여부 호출
    func checkRoomExist() async throws -> Bool {
        
        guard let userId = idHelper?.getUserId() else {
            throw ApiHelperError.nilError
        }
        
        guard let url = URL(string: "https://\(DefaultData.domain)/v1/rooms/exists-by-userId?userId=\(userId)") else {
            throw ApiHelperError.invalidURLError
        }
        
        do {
            let response = try await AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headers)
                .validate(statusCode: 200..<300)
                .serializingDecodable(DefaultResponse.self)
                .value
            
            if response.status == Status.success.rawValue {
                print("DEBUG: Success to check room exist: \(response)")
                
                guard let responseData = response.data else { throw ApiHelperError.responseDataError }
                
                switch responseData {
                case .userDataValue:
                    throw ApiHelperError.responseDataError
                case .intValue:
                    throw ApiHelperError.responseDataError
                case .boolValue(let boolValue):
                    return boolValue
                }
            } else {
                print("DEBUG: Failed to check room exist with error: \(response.message)")
                throw ApiHelperError.networkError(response.message)
            }
        } catch {
            print("DEBUG: Failed to check room exist with error: \(error.localizedDescription)")
            throw ApiHelperError.networkError(error.localizedDescription)
        }
    }
    
    /// 채팅 화면에서 방 상세 정보를 불러오기 위한 호출
    func getRoomDetail() async throws -> RoomDetailData {
        
        guard let userId = idHelper?.getUserId() else {
            throw ApiHelperError.nilError
        }
        
        guard let roomId = idHelper?.getRoomId() else {
            throw ApiHelperError.nilError
        }
        
        guard let url = URL(string: "https://\(DefaultData.domain)/v1/rooms/\(roomId)?userId=\(userId)") else {
            throw ApiHelperError.invalidURLError
        }
        
        do {
            let response = try await AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headers)
                .validate(statusCode: 200..<300)
                .serializingDecodable(RoomDetailDataResponse.self)
                .value
            
            if response.status == Status.success.rawValue {
                print("DEBUG: Success to get room detail")
                
                return response.data
            } else {
                print("DEBUG: Failed to get room detail with error: \(response.message)")
                throw ApiHelperError.networkError(response.message)
            }
        } catch {
            print("DEBUG: Failed to get room detail with error: \(error.localizedDescription)")
            throw ApiHelperError.networkError(error.localizedDescription)
        }
    }
    
    /// 매칭 시간이 끝났는데도 매칭이 안 됐을 경우 GPT와 같이 들어갈 방 생성
    func createRoom() async throws -> String {
        
        guard let userId = idHelper?.getUserId() else {
            throw ApiHelperError.nilError
        }
        
        guard let url = URL(string: "https://\(DefaultData.domain)/v1/rooms") else {
            throw ApiHelperError.invalidURLError
        }
        
        let param: [String: Any] = [
            "userIds": [userId],
            "roomType": "GPT",
        ]
        
        do {
            let response = try await AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: headers)
                .validate(statusCode: 200..<300)
                .serializingDecodable(DefaultResponse.self)
                .value
            
            if response.status == Status.success.rawValue {
                print("DEBUG: Success to create room: \(response)")
                
                guard let responseData = response.data else { throw ApiHelperError.responseDataError }
                
                switch responseData {
                case .userDataValue:
                    throw ApiHelperError.responseDataError
                case .intValue(let intValue):
                    return String(intValue)
                case .boolValue:
                    throw ApiHelperError.responseDataError
                }
            } else {
                print("DEBUG: Failed to create room with error: \(response.message)")
                throw ApiHelperError.networkError(response.message)
            }
        } catch {
            print("DEBUG: Failed to create room with error: \(error.localizedDescription)")
            throw ApiHelperError.networkError(error.localizedDescription)
        }
    }
    
    //MARK: - User
    /// 앱을 처음 실행 시 유저 생성
    func createUser(name: String) async throws {
        
        guard let userId = idHelper?.getUserId() else {
            print("userId is nil")
            throw ApiHelperError.nilError
        }
        
        guard let url = URL(string: "https://\(DefaultData.domain)/v1/users") else {
            throw ApiHelperError.invalidURLError
        }
        
        let param: [String: Any] = [
            "id": userId,
            "name": name,
        ]
        
        do {
            let response = try await AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: headers)
                .validate(statusCode: 200..<300)
                .serializingDecodable(DefaultResponse.self)
                .value
            
            if response.status == Status.success.rawValue {
                print("DEBUG: Success to create user: \(response)")
            } else {
                print("DEBUG: Failed to create user with error: \(response.message)")
                throw ApiHelperError.networkError(response.message)
            }
        } catch {
            print("DEBUG: Failed to create user with error: \(error.localizedDescription)")
            throw ApiHelperError.networkError(error.localizedDescription)
        }
    }
    
    /// 회원 정보를 조회하기 위한 회원 상세조회
    func getUser() async throws -> UserData {
        
        guard let userId = idHelper?.getUserId() else {
            throw ApiHelperError.nilError
        }
        
        guard let url = URL(string: "https://\(DefaultData.domain)/v1/users/\(userId)") else {
            throw ApiHelperError.invalidURLError
        }
        
        do {
            let response = try await AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headers)
                .validate(statusCode: 200..<300)
                .serializingDecodable(DefaultResponse.self)
                .value
            
            if response.status == Status.success.rawValue {
                print("DEBUG: Success to get user: \(response)")
                guard let responseData = response.data else { throw ApiHelperError.responseDataError }
                
                switch responseData {
                case .userDataValue(let userDataValue):
                    return userDataValue
                case .intValue:
                    throw ApiHelperError.responseDataError
                case .boolValue:
                    throw ApiHelperError.responseDataError
                }
            } else {
                print("DEBUG: Failed to get user with error: \(response.message)")
                throw ApiHelperError.networkError(response.message)
            }
        } catch {
            print("DEBUG: Failed to get user with error: \(error.localizedDescription)")
            throw ApiHelperError.networkError(error.localizedDescription)
        }
    }
    
    /// 회원 닉네임 수정을 위한 회원 수정
    func updateUserName(name: String) async throws {
        
        guard let userId = idHelper?.getUserId() else {
            throw ApiHelperError.nilError
        }
        
        guard let url = URL(string: "https://\(DefaultData.domain)/v1/users/\(userId)") else {
            throw ApiHelperError.invalidURLError
        }
        
        let param: [String: Any] = [
            "name": name,
        ]
        
        do {
            let response = try await AF.request(url, method: .put, parameters: param, encoding: JSONEncoding.default, headers: headers)
                .validate(statusCode: 200..<300)
                .serializingDecodable(DefaultResponse.self)
                .value
            
            if response.status == Status.success.rawValue {
                print("DEBUG: Success to update user name: \(response)")
            } else {
                print("DEBUG: Failed to update user name with error: \(response.message)")
                throw ApiHelperError.networkError(response.message)
            }
        } catch {
            print("DEBUG: Failed to update user name with error: \(error.localizedDescription)")
            throw ApiHelperError.networkError(error.localizedDescription)
        }
    }
    
    //MARK: - Chat
    /// 기존에 채팅한 목록 조회
    func getMessages(page: Int = 0, size: Int = 20) async throws -> MessagesListResponseData {
        
        guard let roomId = idHelper?.getRoomId() else {
            throw ApiHelperError.nilError
        }
        
        guard let url = URL(string: "https://\(DefaultData.domain)/v1/rooms/\(roomId)/messages?page=\(page)&size=\(size)") else {
            throw ApiHelperError.invalidURLError
        }
        
        print("getMessages: https://\(DefaultData.domain)/v1/rooms/\(roomId)/messages?page=\(page)&size=\(size)")
        do {
            let response = try await AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headers)
                .validate(statusCode: 200..<300)
                .serializingDecodable(MessageListResponse.self)
                .value
            
            if response.status == Status.success.rawValue {
                print("DEBUG: Success to get messages: \(response.data)")
                return response.data
            } else {
                print("DEBUG: Failed to get messages with error: \(response.message)")
                throw ApiHelperError.networkError(response.message)
            }
        } catch {
            print("DEBUG: Failed to get messages with error: \(error.localizedDescription)")
            throw ApiHelperError.networkError(error.localizedDescription)
        }
        
    }
}
