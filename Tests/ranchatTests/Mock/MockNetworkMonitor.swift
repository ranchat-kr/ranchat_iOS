//
//  MockNetworkMonitor.swift
//  ranchatTests
//

@testable import ranchat

final class MockNetworkMonitor: NetworkMonitorProtocol {
    var isConnected: Bool

    init(isConnected: Bool = true) {
        self.isConnected = isConnected
    }
}
