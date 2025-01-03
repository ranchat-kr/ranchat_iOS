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
    let className = "HomeViewModel"
    
    var showNetworkErrorDialog = false
    var isLoading = false
    var isMatching = false
    var isRoomExist = false
    var isInitialized = false
    
    var goToSetting = false
    var goToChat = false
    var goToRoomList = false
    
    var navigationPath = NavigationPath()
    
    var webSocketHelper: WebSocketHelper?
    var idHelper: IdHelper?
    var networkMonitor: NetworkMonitor?
    
    func setHelper(_ webSocketHelper: WebSocketHelper,_ idHelper: IdHelper) {
        self.webSocketHelper = webSocketHelper
        self.idHelper = idHelper
    }
    
    func setNetworkMonitor(_ networkMonitor: NetworkMonitor) {
        self.networkMonitor = networkMonitor
    }
    
    func navigateToChat() {
        goToChat = true
    }
    
    func navigateToRoomList() {
        goToRoomList = true
    }
    
    func navigateToSetting() {
        goToSetting = true
    }
    
    func setUser() {
        
        isLoading = true
        
                @AppStorage("user_id") var user: String?
        

        
        
        guard let webSocketHelper, let idHelper else {
            Logger.shared.log(self.className, #function, "webSocketHelper or idHelper is nil", .error)
            
            return
        }
        
        Task {
            do {
                if let user {  // 기존 유저
                    idHelper.setUserId(user)
                } else {  // 새로운 유저 (앱 처음 실행)
                    let uuid = UUID.uuidV7String()
                    user = uuid
                    idHelper.setUserId(uuid)
                    try await ApiHelper.shared.createUser(name: getRandomNickname())
                    
                }
                try webSocketHelper.connectToWebSocket()
                await checkRoomExist()
                self.isInitialized = true
            } catch {
                showNetworkErrorDialog = true
                
                Logger.shared.log(self.className, #function, "Failed to set user: \(error.localizedDescription)", .error)
            }
        }
        
        isLoading = false
    }
    
    func successMatching() {
        isMatching = false
        
        if !(networkMonitor?.isConnected ?? false) {
            showNetworkErrorDialog = true
            return
        }
        
        guard let webSocketHelper else {
            Logger.shared.log(self.className, #function, "webSocketHelper is nil")
            
            return
        }
        
        do {
            try webSocketHelper.cancelMatching()
            try webSocketHelper.enterRoom()
            navigateToChat()
        } catch {
            showNetworkErrorDialog = true
            
            Logger.shared.log(self.className, #function, "Failed to success matching: \(error.localizedDescription)", .error)
        }
    }
    
    func requestMatching() {
        if !(networkMonitor?.isConnected ?? false) {
            showNetworkErrorDialog = true
            return
        }
        
        if let networkMonitor, !networkMonitor.isConnected {
            showNetworkErrorDialog = true
            return
        }
        
        isMatching = true
        
        guard let webSocketHelper else {
            Logger.shared.log(self.className, #function, "webSocketHelper is nil", .error)
            isMatching = false
            return
        }
        
        do {
            try webSocketHelper.requestMatching()
            checkMatching()
        } catch {
            isMatching = false
            showNetworkErrorDialog = true
    
            Logger.shared.log(self.className, #function, "Failed to request matching: \(error.localizedDescription)", .error)
        }
    }
    
    func checkMatching() {
        guard let webSocketHelper, let idHelper else {
            Logger.shared.log(self.className, #function, "webSocketHelper or idHelper is nil", .error)
            
            return
        }
        
        Task {
            do {
                try await Task.sleep(for: .seconds(8))
                
                if !isMatching { return }
                
                isMatching = false
                
                if !(networkMonitor?.isConnected ?? false) {
                    showNetworkErrorDialog = true
                    return
                }
                
                try webSocketHelper.cancelMatching()
                if !webSocketHelper.isMatchSuccess {  //8초가 지나도 매칭이 안 됐을 경우, GPT와 연결 (방을 인위적으로 만들어 나온 roomId로 설정)
                    let roomId = try await ApiHelper.shared.createRoom()
                    idHelper.setRoomId(roomId)
                }   
                try webSocketHelper.enterRoom()
                navigateToChat()
            } catch {
                isMatching = false
                showNetworkErrorDialog = true
                
                Logger.shared.log(self.className, #function, "Failed to check matching: \(error.localizedDescription)", .error)
            }
        }
    }
    
    func checkRoomExist() async {
        isLoading = true
        
        Task {
            do {
                self.isRoomExist = try await ApiHelper.shared.checkRoomExist()
            } catch {
                showNetworkErrorDialog = true
                
                Logger.shared.log(self.className, #function, "Failed to check room exist: \(error.localizedDescription)", .error)
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
