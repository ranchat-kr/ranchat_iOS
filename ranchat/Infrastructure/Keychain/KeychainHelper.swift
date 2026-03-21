//
//  KeychainHelper.swift
//  ranchat
//

import Foundation
import Security

final class KeychainHelper {
    static let shared = KeychainHelper()
    private init() {}

    private let service = "net.ranchat.app"
    private let accountKey = "userId"

    func getUserId() -> String? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: accountKey,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess,
              let data = result as? Data,
              let id = String(data: data, encoding: .utf8) else {
            return nil
        }
        return id
    }

    @discardableResult
    func saveUserId(_ id: String) -> Bool {
        guard let data = id.data(using: .utf8) else { return false }
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: accountKey,
            kSecValueData: data
        ]
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            Logger.shared.log("KeychainHelper", #function, "Failed to save userId: \(status)", .error)
        }
        return status == errSecSuccess
    }

    @discardableResult
    func deleteUserId() -> Bool {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: accountKey
        ]
        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            Logger.shared.log("KeychainHelper", #function, "Failed to delete userId: \(status)", .error)
        }
        return status == errSecSuccess || status == errSecItemNotFound
    }
}
