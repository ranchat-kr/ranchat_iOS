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
    case SpecialCharacter
    case ContainsForbiddenCharacter
    case None
}

@Observable
class SettingViewModel {
    let className = "SettingViewModel"
    
    var isLoading: Bool = false
    var showNetworkErrorAlert: Bool = false
    var showCheckNickNameAlert: Bool = false
    var showSuccessToast: Bool = false
    var showInValidToast: Bool = false
    
    var user: UserData?
    
    var nicknameError: nickNameError = .None
    
    var editNickName = ""
    
    func setUser() {
        isLoading = true
        
        Task {
            do {
                user = try await ApiHelper.shared.getUser()
            } catch {
                showNetworkErrorAlert = true
                
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
                showNetworkErrorAlert = true
                
                Logger.shared.log(self.className, #function, "Failed to update user name: \(error.localizedDescription)", .error)
            }
        }
        
        isLoading = false
    }
    
    func isValidNickname() -> Bool {
        let forbiddenWords = [
            "admin", "administrator", "sex", "섹스"
        ]
        
        let specialCharRegex = "[!@#<>?\":_`~;\\[\\]\\\\|=+)(*&^%0-9-]"
        
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
}
