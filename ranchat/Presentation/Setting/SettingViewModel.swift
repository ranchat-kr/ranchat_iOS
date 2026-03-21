//
//  SettingViewModel.swift
//  ranchat
//

import SwiftUI

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

    var user: User?
    var nicknameError: NicknameError = .none
    var editNickName: String = ""

    private var getUserUseCase: any GetUserUseCase
    private var updateUserNameUseCase: any UpdateUserNameUseCase
    private var updateNotificationUseCase: any UpdateNotificationUseCase
    private var validateNicknameUseCase: any ValidateNicknameUseCase

    init(
        getUserUseCase: any GetUserUseCase = DefaultGetUserUseCase(),
        updateUserNameUseCase: any UpdateUserNameUseCase = DefaultUpdateUserNameUseCase(),
        updateNotificationUseCase: any UpdateNotificationUseCase = DefaultUpdateNotificationUseCase(),
        validateNicknameUseCase: any ValidateNicknameUseCase = DefaultValidateNicknameUseCase()
    ) {
        self.getUserUseCase = getUserUseCase
        self.updateUserNameUseCase = updateUserNameUseCase
        self.updateNotificationUseCase = updateNotificationUseCase
        self.validateNicknameUseCase = validateNicknameUseCase
    }

    func setUser() {
        guard let userId = KeychainHelper.shared.getUserId() else {
            Logger.shared.log(className, #function, "userId is nil", .error)
            showNetworkErrorDialog = true
            return
        }

        isLoading = true
        Task {
            do {
                user = try await getUserUseCase.execute(userId: userId)
                self.isInitialized = true
            } catch {
                showNetworkErrorDialog = true
                Logger.shared.log(className, #function, "Failed to get user: \(error.localizedDescription)", .error)
            }
            isLoading = false
        }
    }

    func setNickname() {
        guard let userId = KeychainHelper.shared.getUserId() else {
            Logger.shared.log(className, #function, "userId is nil", .error)
            showNetworkErrorDialog = true
            return
        }

        isLoading = true
        Task {
            do {
                try await updateUserNameUseCase.execute(userId: userId, name: editNickName)
                user?.setName(editNickName)
                editNickName = ""
                showSuccessToast = true
            } catch {
                showNetworkErrorDialog = true
                Logger.shared.log(className, #function, "Failed to update user name: \(error.localizedDescription)", .error)
            }
            isLoading = false
        }
    }

    func isValidNickname() -> Bool {
        let error = validateNicknameUseCase.execute(nickname: editNickName, currentName: user?.name)
        nicknameError = error
        if error != .none {
            showInValidToast = true
            return false
        }
        return true
    }

    func updateNotification() {
        guard let userId = KeychainHelper.shared.getUserId() else {
            Logger.shared.log(className, #function, "userId is nil", .error)
            return
        }

        Task {
            do {
                try await updateNotificationUseCase.execute(
                    userId: userId,
                    agentId: DefaultData.shared.agentId ?? "",
                    allowsNotification: isToggleOn
                )
            } catch {
                showNetworkErrorDialog = true
            }
        }
    }
}
