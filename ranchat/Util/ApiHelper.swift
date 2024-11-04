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
    let className = "ApiHelper"
    var idHelper: IdHelper?
    
    let headers: HTTPHeaders = ["Content-Type": "application/json", "Accept": "application/json"]
//    let roomId: String = "1"
//    let userId: String = "0190964c-ee3a-7e81-a1f8-231b5d97c2a1"
    
    func setIdHelper(idHelper: IdHelper) {
        self.idHelper = idHelper
    }
    
    //MARK: - Notifications
    /// 앱 알림 생성
    func createNotifications(allowsNotification: Bool, agentId: String, osType: String, deviceName: String) async throws {
        let userId = try getUserId()
        let url = try getUrl(for: "https://\(DefaultData.domain)/v1/app-notifications")
        
        let param: [String: Any] = [
            "allowsNotification": allowsNotification,
            "agentId": agentId,
            "osType": osType,
            "deviceName": deviceName,
            "userId": userId
            ]
        
        do {
            let response = try await AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: headers)
                .validate(statusCode: 200..<300)
                .serializingDecodable(DefaultResponse.self)
                .value
            
            if response.status == Status.success.rawValue {
                Logger.shared.log(self.className, #function, "Success to create notifications: \(response)")
            } else {
                Logger.shared.log(self.className, #function, "Failed to create notifications with error: \(response.message)", .error)
                
                throw ApiHelperError.networkError(response.message)
            }
        } catch {
            Logger.shared.log(self.className, #function, "Failed to create notifications with error: \(error.localizedDescription)", .error)
            
            throw ApiHelperError.networkError(error.localizedDescription)
        }
    }
    
    /// 앱 알림 수정
    func updateAppNotifications(agentId: String, allowsNotification: Bool) async throws {
        let userId = try getUserId()
        let url = try getUrl(for: "https://\(DefaultData.domain)/v1/app-Notifications")
        
        let param: [String: Any] = [
            "userId": userId,
            "agentId": agentId,
            "allowsNotification": allowsNotification
        ]
        
        do {
            let response = try await AF.request(url, method: .put, parameters: param, encoding: JSONEncoding.default, headers: headers)
                .validate(statusCode: 200..<300)
                .serializingDecodable(DefaultResponse.self)
                .value
            
            if response.status == Status.success.rawValue {
                Logger.shared.log(self.className, #function, "Success to update app notifications: \(response)")
            } else {
                Logger.shared.log(self.className, #function, "Failed to update app notifications with error: \(response.message)", .error)
                
                throw ApiHelperError.networkError(response.message)
            }
        } catch {
            Logger.shared.log(self.className, #function, "Failed to update app notifications with error: \(error.localizedDescription)", .error)
            
            throw ApiHelperError.networkError(error.localizedDescription)
        }
    }
    
    //MARK: - Report
    /// 유저 신고하기
    func reportUser(reportedUserId: String, reportReason: String, reportType: String) async throws {
        let userId = try getUserId()
        let roomId = try getRoomId()
        let url = try getUrl(for: "https://\(DefaultData.domain)/v1/reports")
        
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
                Logger.shared.log(self.className, #function, "Success to report user: \(response)")
            } else {
                Logger.shared.log(self.className, #function, "Failed to report user with error: \(response.message)", .error)
                
                throw ApiHelperError.networkError(response.message)
            }
            
        } catch {
            Logger.shared.log(self.className, #function, "Failed to report user with error: \(error.localizedDescription)", .error)
            
            throw ApiHelperError.networkError(error.localizedDescription)
        }
    }
    
    //MARK: - ChatRoom
    /// CONTINUE! 화면에서 나오는 방 리스트 호출
    func getRooms(page: Int = 0, size: Int = 10) async throws -> RoomDataList {
        let userId = try getUserId()
        let url = try getUrl(for: "https://\(DefaultData.domain)/v1/rooms?page=\(page)&size=\(size)&userId=\(userId)")
                
        do {
            let response = try await AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headers)
                .validate(statusCode: 200..<300)
                .serializingDecodable(RoomDataList.self)
                .value
            
            if response.status == Status.success.rawValue {
                Logger.shared.log(self.className, #function, "Success to get rooms: \(response)")
                
                return response
            } else {
                Logger.shared.log(self.className, #function, "Failed to get rooms with error: \(response.message)", .error)
                
                throw ApiHelperError.networkError(response.message)
            }
        } catch {
            Logger.shared.log(self.className, #function, "Failed to get rooms with error: \(error.localizedDescription)", .error)
            
            throw ApiHelperError.networkError(error.localizedDescription)
        }
    }
    
    /// HOME화면에서 CONTINUE! 버튼의 Visible유무를 판단하기 위한 방 존재 여부 호출
    func checkRoomExist() async throws -> Bool {
        let userId = try getUserId()
        let url = try getUrl(for: "https://\(DefaultData.domain)/v1/rooms/exists-by-userId?userId=\(userId)")
        
        do {
            let response = try await AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headers)
                .validate(statusCode: 200..<300)
                .serializingDecodable(DefaultResponse.self)
                .value
            
            if response.status == Status.success.rawValue {
                Logger.shared.log(self.className, #function, "Successfully checked room exist")
                
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
                Logger.shared.log(self.className, #function, "Failed to check room exist with error: \(response.message)", .error)
                
                throw ApiHelperError.networkError(response.message)
            }
        } catch {
            Logger.shared.log(self.className, #function, "Failed to check room exist with error: \(error.localizedDescription)", .error)
            
            throw ApiHelperError.networkError(error.localizedDescription)
        }
    }
    
    /// 채팅 화면에서 방 상세 정보를 불러오기 위한 호출
    func getRoomDetail() async throws -> RoomDetailData {
        let userId = try getUserId()
        let roomId = try getRoomId()
        let url = try getUrl(for: "https://\(DefaultData.domain)/v1/rooms/\(roomId)?userId=\(userId)")
        
        do {
            let response = try await AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headers)
                .validate(statusCode: 200..<300)
                .serializingDecodable(RoomDetailDataResponse.self)
                .value
            
            if response.status == Status.success.rawValue {
                Logger.shared.log(self.className, #function, "Success to get room detail with data: \(response.data)")
                
                return response.data
            } else {
                Logger.shared.log(self.className, #function, "Failed to get room detail with error: \(response.message)", .error)
                
                throw ApiHelperError.networkError(response.message)
            }
        } catch {
            Logger.shared.log(self.className, #function, "Failed to get room detail with error: \(error.localizedDescription)", .error)
            
            throw ApiHelperError.networkError(error.localizedDescription)
        }
    }
    
    /// 매칭 시간이 끝났는데도 매칭이 안 됐을 경우 GPT와 같이 들어갈 방 생성
    func createRoom() async throws -> String {
        let userId = try getUserId()
        let url = try getUrl(for: "https://\(DefaultData.domain)/v1/rooms")
        
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
                Logger.shared.log(self.className, #function, "Success to create room: \(response)")
                
                guard let responseData = response.data else {
                    Logger.shared.log(self.className, #function, "Failed to get response data", .error)
                    
                    throw ApiHelperError.responseDataError
                }
                
                switch responseData {
                case .userDataValue:
                    throw ApiHelperError.responseDataError
                case .intValue(let intValue):
                    return String(intValue)
                case .boolValue:
                    throw ApiHelperError.responseDataError
                }
            } else {
                Logger.shared.log(self.className, #function, "Faile to create room with error: \(response.message)", .error)
                
                throw ApiHelperError.networkError(response.message)
            }
        } catch {
            Logger.shared.log(self.className, #function, "Failed to create room with error: \(error.localizedDescription)", .error)
            
            throw ApiHelperError.networkError(error.localizedDescription)
        }
    }
    
    //MARK: - User
    /// 앱을 처음 실행 시 유저 생성
    func createUser(name: String) async throws {
        let userId = try getUserId()
        let url = try getUrl(for: "https://\(DefaultData.domain)/v1/users")
        
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
                Logger.shared.log(self.className, #function, "Success to create user: \(response)")
            } else {
                Logger.shared.log(self.className, #function, "Failed to create user: \(response.message)", .error)
                
                throw ApiHelperError.networkError(response.message)
            }
        } catch {
            Logger.shared.log(self.className, #function, "Failed to create user with error: \(error.localizedDescription)", .error)
            
            throw ApiHelperError.networkError(error.localizedDescription)
        }
    }
    
    /// 회원 정보를 조회하기 위한 회원 상세조회
    func getUser() async throws -> UserData {
        let userId = try getUserId()
        let url = try getUrl(for: "https://\(DefaultData.domain)/v1/users/\(userId)")
        
        do {
            let response = try await AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headers)
                .validate(statusCode: 200..<300)
                .serializingDecodable(DefaultResponse.self)
                .value
            
            if response.status == Status.success.rawValue {
                Logger.shared.log(self.className, #function, "Success to get user: \(response)")
                guard let responseData = response.data else {
                    Logger.shared.log(self.className, #function, "Failed to get user: responseData is nil", .error)
                    
                    throw ApiHelperError.responseDataError
                }
                
                switch responseData {
                case .userDataValue(let userDataValue):
                    return userDataValue
                case .intValue:
                    throw ApiHelperError.responseDataError
                case .boolValue:
                    throw ApiHelperError.responseDataError
                }
            } else {
                Logger.shared.log(self.className, #function, "Failed to get user: \(response.message)", .error)
                
                throw ApiHelperError.networkError(response.message)
            }
        } catch {
            Logger.shared.log(self.className, #function, "Failed to get user with error: \(error.localizedDescription)", .error)
            
            throw ApiHelperError.networkError(error.localizedDescription)
        }
    }
    
    /// 회원 닉네임 수정을 위한 회원 수정
    func updateUserName(name: String) async throws {
        let userId = try getUserId()
        let url = try getUrl(for: "https://\(DefaultData.domain)/v1/users/\(userId)")
        
        let param: [String: Any] = [
            "name": name,
        ]
        
        do {
            let response = try await AF.request(url, method: .put, parameters: param, encoding: JSONEncoding.default, headers: headers)
                .validate(statusCode: 200..<300)
                .serializingDecodable(DefaultResponse.self)
                .value
            
            if response.status == Status.success.rawValue {
                Logger.shared.log(self.className, #function, "Success to update user name: \(response)")
            } else {
                Logger.shared.log(self.className, #function, "Faile to update user name: \(response.message)", .error)
                
                throw ApiHelperError.networkError(response.message)
            }
        } catch {
            Logger.shared.log(self.className, #function, "Fair to update user name with error: \(error.localizedDescription)", .error)
            
            throw ApiHelperError.networkError(error.localizedDescription)
        }
    }
    
    //MARK: - Chat
    /// 기존에 채팅한 목록 조회
    func getMessages(page: Int = 0, size: Int = 20) async throws -> MessagesListResponseData {
        let roomId = try getRoomId()
        let url = try getUrl(for: "https://\(DefaultData.domain)/v1/rooms/\(roomId)/messages?page=\(page)&size=\(size)")
        
        do {
            let response = try await AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headers)
                .validate(statusCode: 200..<300)
                .serializingDecodable(MessageListResponse.self)
                .value
            
            if response.status == Status.success.rawValue {
                Logger.shared.log(self.className, #function, "Success to get messages: \(response.data)")
                
                return response.data
            } else {
                Logger.shared.log(self.className, #function, "Failed to get messages: \(response.message)", .error)
                
                throw ApiHelperError.networkError(response.message)
            }
        } catch {
            Logger.shared.log(self.className, #function, "Failed to get messages with error: \(error.localizedDescription)", .error)
            
            throw ApiHelperError.networkError(error.localizedDescription)
        }
        
    }
    
    //MARK: - Get
    func getUserId() throws -> String {
        guard let userId = idHelper?.getUserId() else {
            Logger.shared.log(self.className, #function, "Failed to get user id", .error)
            
            throw ApiHelperError.nilError
        }
        
        return userId
    }
    
    func getRoomId() throws -> String {
        guard let roomId = idHelper?.getRoomId() else {
            Logger.shared.log(self.className, #function, "Failed to get room id", .error)
            
            throw ApiHelperError.nilError
        }
        
        return roomId
    }
    
    func getUrl(for path: String) throws -> URL {
        guard let url = URL(string: path) else {
            Logger.shared.log(self.className, #function, "Failed to create URL from path: \(path)")
            
            throw ApiHelperError.invalidURLError
        }
        return url
    }
}
