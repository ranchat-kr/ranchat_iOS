//
//  HomeViewModel.swift
//  ranchat
//
//  Created by 김견 on 9/9/24.
//

import UUIDV7
import SwiftUI

@Observable
class HomeViewModel {
    var showAlert = false
    var isLoading = false
    var isRoomExist = false
    
    func setUser(idHelper: IdHelper, webSocketHelper: WebSocketHelper) {
        @AppStorage("user_id") var user: String?
        user = nil  // 임시. 초기화.
        
        isLoading = true
        
        if let user {  // 기존 유저
            idHelper.setUserId(user)
        } else {  // 새로운 유저 (앱 처음 실행)
            let uuid = UUID.uuidV7String()
            user = uuid
            idHelper.setUserId(uuid)
            
            Task {
                do {
                    try await ApiHelper.shared.createUser(name: getRandomNickname())
                    try webSocketHelper.connectToWebSocket(idHelper: idHelper)
                    await checkRoomExist()
                } catch {
                    showAlert = true
                }
            }
        }
        
        isLoading = false
    }
    
    func checkRoomExist() async {
        isLoading = true
        
        Task {
            do {
                self.isRoomExist = try await ApiHelper.shared.checkRoomExist()
            } catch {
                showAlert = true
            }
        }
        
        isLoading = false
    }
    
    func getRandomNickname() -> String {
        let frontNickname = [
            "행복한", "빛나는", "빠른", "작은", "푸른", "깊은", "웃는", "고요한", "따뜻한", "하얀", "즐거운", "맑은", "예쁜", "강한", "조용한", "푸른", "따뜻한", "밝은", "신비한", "높은",
        ]
        let backNickname = [
            "고양이", "별", "바람", "새", "하늘", "바다", "사람", "숲", "햇살", "눈", "여행", "강", "꽃", "용", "밤", "나무", "마음", "햇빛", "섬", "산",
        ]
        
        return (frontNickname.randomElement() ?? "") + (backNickname.randomElement() ?? "")
    }
}
