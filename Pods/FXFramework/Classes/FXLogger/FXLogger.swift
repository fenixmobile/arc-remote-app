//
//  FXLogger.swift
//
//
//  Created by Savaş Salihoğlu on 12.10.2023.
//

import Foundation
//import FXFramework

enum FXLogger {
    
    static var logLevel: FXLogLevel = .info
    static var version: String = "0.1.24"
    private static let dispatchQueue = DispatchQueue(label: "fx.framework.Logger")
    
    static func write(_ level: FXLogLevel,
             message: String,
             file: String = #fileID,
             function: String = #function,
             line: UInt = #line) {
        guard logLevel.rawValue >= level.rawValue else { return }
        dispatchQueue.async {
            if logLevel.rawValue >= FXLogLevel.debug.rawValue {
                print("[FX v\(version)] - \(level)\t\(file)#\(line): \(message)")
            } else {
                print("[FX v\(version)] - \(level): \(message)")
            }
        }
    }
    
}
/*
extension FX {
    public static var logLevel: FXLogLevel {
        get { FXLogger.logLevel }
        set { FXLogger.logLevel = newValue }
    }
}*/

public enum FXLog {

    public static func error(_ message: String, file: String = #fileID, function: String = #function, line: UInt = #line) {
        FXLogger.write(.error, message: message, file: file, function: function, line: line)
    }

    public static func warn(_ message: String, file: String = #fileID, function: String = #function, line: UInt = #line) {
        FXLogger.write(.warn, message: message, file: file, function: function, line: line)
    }

    public static func info(_ message: String, file: String = #fileID, function: String = #function, line: UInt = #line) {
        FXLogger.write(.info, message: message, file: file, function: function, line: line)
    }

    public static func verbose(_ message: String, file: String = #fileID, function: String = #function, line: UInt = #line) {
        FXLogger.write(.verbose, message: message, file: file, function: function, line: line)
    }
    
    public static func debug(_ message: String, file: String = #fileID, function: String = #function, line: UInt = #line) {
        FXLogger.write(.debug, message: message, file: file, function: function, line: line)
    }
}
