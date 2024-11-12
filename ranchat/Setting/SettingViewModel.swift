//
//  SettingViewModel.swift
//  ranchat
//
//  Created by 김견 on 10/8/24.
//

import SwiftUI

enum nickNameError {
    case Empty
    case Length
    case ContainsBlank
    case Duplicate
    case SpecialCharacter
    case ContainsForbiddenCharacter
    case None
}

@Observable
class SettingViewModel {
    let className = "SettingViewModel"
    
    var isLoading: Bool = false
    var isInitialized: Bool = false
    var showNetworkErrorDialog: Bool = false
    var showCheckNickNameDialog: Bool = false
    var showSuccessToast: Bool = false
    var showInValidToast: Bool = false
    var isToggleOn: Bool = DefaultData.shared.isNotificationEnabled
    
    var user: UserData?
    
    var nicknameError: nickNameError = .None
    
    var editNickName: String = ""
    
    func setUser() {
        isLoading = true
        
        Task {
            do {
                user = try await ApiHelper.shared.getUser()
                self.isInitialized = true
            } catch {
                showNetworkErrorDialog = true
                
                Logger.shared.log(self.className, #function, "Failed to get user: \(error.localizedDescription)", .error)
            }
        }
        
        isLoading = false
    }
    
    func setNickname() {
        isLoading = true
        
        Task {
            do {
                try await ApiHelper.shared.updateUserName(name: editNickName)
                user?.setName(editNickName)
                editNickName = ""
                showSuccessToast = true
            } catch {
                showNetworkErrorDialog = true
                
                Logger.shared.log(self.className, #function, "Failed to update user name: \(error.localizedDescription)", .error)
            }
        }
        
        isLoading = false
    }
    
    func isValidNickname() -> Bool {
        let forbiddenWords = [
            "씨발", "좆", "개새끼", "병신", "미친놈", "엿", "썅", "엿같은", "시발", "썩을", "멍청이", "바보", "븅신", "좃같은", "엿먹어",
            "성기", "야동", "포르노", "섹스", "섹시", "변태", "성인물", "AV", "자위", "성욕", "야사", "음란", "야설", "발정", "성행위", "강간", "노출",
            "흑인", "백인", "유태인", "장애인", "쪽바리", "중국놈", "왜놈", "일베", "혐오",
            "살인", "테러", "자살", "죽여", "협박", "살인자", "죽음", "무기", "총기", "학살", "납치", "폭발",
            "공산당", "민주당", "공화당", "종북", "나치", "파시스트", "레닌", "이슬람국가", "탈레반",
            "도박", "대출", "사기", "불법", "복권", "대포통장", "카드깡", "마약", "필로폰", "대마초", "아편", "마약사범", "범죄",
            "우울증", "정신병", "발암", "암덩어리", "병자", "쓸모없는", "혐오", "무가치", "비참한", "저주"
        ]
        
        let specialCharRegex = "[^\\p{L}\\p{N}]"
        
        if editNickName.isEmpty {
            nicknameError = .Empty
            
            showInValidToast = true
            
            return false
        } else if editNickName.count < 2 || editNickName.count > 10 {
            nicknameError = .Length
            
            showInValidToast = true
            
            return false
        } else if editNickName.contains(" ") {
            nicknameError = .ContainsBlank
            
            showInValidToast = true
            
            return false
        } else if let user, user.name == editNickName {
            nicknameError = .Duplicate
            
            showInValidToast = true
            
            return false
        } else if let regex = try? NSRegularExpression(pattern: specialCharRegex, options: []) {
            let range = NSRange(location: 0, length: editNickName.utf16.count)
            let matchFound = regex.firstMatch(in: editNickName, options: [], range: range) != nil
            if matchFound {
                nicknameError = .SpecialCharacter
                
                showInValidToast = true
                
                return false
            }
        }
        
        for forbiddenWord in forbiddenWords {
            if editNickName.contains(forbiddenWord) {
                nicknameError = .ContainsForbiddenCharacter
                
                showInValidToast = true
                
                return false
            }
        }
        return true
    }
    
    func updateNotification() {
        Task {
            do {
                try await ApiHelper.shared.updateAppNotifications(
                    agentId: DefaultData.shared.agentId ?? "",
                    allowsNotification: isToggleOn
                )
            } catch {
                showNetworkErrorDialog = true
            }
        }
    }
}
