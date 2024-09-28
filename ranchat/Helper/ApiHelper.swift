//
//  ApiHelper.swift
//  ranchat
//
//  Created by 김견 on 9/14/24.
//

import Foundation
import Alamofire

enum ApiHelperError: Error {
    case invalidURLError
    case networkError(String)
}

class ApiHelper {
    static let shared = ApiHelper()
    
    let headers: HTTPHeaders = ["Content-Type": "application/json", "Accept": "application/json"]
    let roomId: String = "1"
    let userId: String = "0190964c-ee3a-7e81-a1f8-231b5d97c2a1"
    
    //MARK: - Report
    func reportUser(reportedUserId: String, selectedReason: String, reportReason: String, reportType: String) async throws {
        
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
            
            print("DEBUG: Success to report user: \(response)")
            
        } catch {
            print("DEBUG: Failed to report user with error: \(error.localizedDescription)")
            throw ApiHelperError.networkError(error.localizedDescription)
        }
    }
    
    //MARK: - ChatRoom
    func getRooms(page: Int = 0, size: Int = 10) async throws -> [RoomData] {
        guard let url = URL(string: "https://\(DefaultData.domain)/v1/rooms?page=\(page)&size=\(size)&userId=\(userId)") else {
            throw ApiHelperError.invalidURLError
        }
                
        do {
            let response = try await AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headers)
                .validate(statusCode: 200..<300)
                .serializingDecodable(RoomDataList.self)
                .value
            
            print("DEBUG: Success to get rooms: \(response)")
            return response.data.items
        } catch {
            print("DEBUG: Failed to get rooms with error: \(error.localizedDescription)")
            throw ApiHelperError.networkError(error.localizedDescription)
        }
    }
    
    func checkRoomExist() async throws -> Bool {
        guard let url = URL(string: "https://\(DefaultData.domain)/v1/rooms/exists-by-userId?userId=\(userId)") else {
            throw ApiHelperError.invalidURLError
        }
        
        do {
            let response = try await AF.request(url, method: .get, encoding: JSONEncoding.default, headers: headers)
                .validate(statusCode: 200..<300)
                .serializingDecodable(DefaultResponse.self)
                .value
            
            print("DEBUG: Success to check room exist: \(response)")
            
            if let isRoomExist = response.data {
                return isRoomExist
            } else {
                return false
            }
        } catch {
            print("DEBUG: Failed to check room exist with error: \(error.localizedDescription)")
            throw ApiHelperError.networkError(error.localizedDescription)
        }
    }
}
