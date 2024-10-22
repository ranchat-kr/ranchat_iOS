//
//  Logger.swift
//  ranchat
//
//  Created by 김견 on 10/22/24.
//

enum LogLevel: String {
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
}

class Logger {
    static let shared = Logger()
    static var isEnabled: Bool = true
    
    func log(_ className: String, _ functionName: String, _ message: String, _ level: LogLevel = .debug) {
        guard Logger.isEnabled else { return }
        
        print("[\(level.rawValue)] [\(className)] - \(functionName) \(message)")
        
    }
}
