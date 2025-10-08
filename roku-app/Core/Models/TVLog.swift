//
//  TVLog.swift
//  roku-app
//
//  Created by Sengel on 8.09.2025.
//

import Foundation
import UIKit

struct TVLog: Codable {
    let id: String
    let timestamp: Date
    let deviceInfo: DeviceLogInfo
    let connectionStatus: ConnectionStatus
    let action: LogAction
    let details: LogDetails?
    let appVersion: String
    let deviceModel: String
    let osVersion: String
    
    init(deviceInfo: DeviceLogInfo, connectionStatus: ConnectionStatus, action: LogAction, details: LogDetails? = nil) {
        self.id = UUID().uuidString
        self.timestamp = Date()
        self.deviceInfo = deviceInfo
        self.connectionStatus = connectionStatus
        self.action = action
        self.details = details
        self.appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        self.deviceModel = UIDevice.current.model
        self.osVersion = UIDevice.current.systemVersion
    }
}

struct DeviceLogInfo: Codable {
    let brand: String
    let name: String
    let ipAddress: String
    let port: Int
    let customName: String?
    
    init(from device: TVDevice) {
        self.brand = device.brand.rawValue
        self.name = device.name
        self.ipAddress = device.ipAddress
        self.port = device.port
        self.customName = device.customName
    }
}

enum ConnectionStatus: String, Codable {
    case connected = "connected"
    case disconnected = "disconnected"
    case connecting = "connecting"
    case failed = "failed"
    case timeout = "timeout"
    case unknown = "unknown"
}

enum LogAction: String, Codable {
    case deviceDiscovery = "device_discovery"
    case connectionAttempt = "connection_attempt"
    case connectionSuccess = "connection_success"
    case connectionFailed = "connection_failed"
    case commandSent = "command_sent"
    case commandFailed = "command_failed"
    case deviceAdded = "device_added"
    case deviceRemoved = "device_removed"
    case appLaunch = "app_launch"
    case appBackground = "app_background"
    case appForeground = "app_foreground"
}

struct LogDetails: Codable {
    let command: String?
    let errorMessage: String?
    let responseTime: Double?
    let networkType: String?
    let batteryLevel: Float?
    let wifiSSID: String?
    let additionalData: [String: String]?
    
    init(command: String? = nil, 
         errorMessage: String? = nil, 
         responseTime: Double? = nil,
         networkType: String? = nil,
         batteryLevel: Float? = nil,
         wifiSSID: String? = nil,
         additionalData: [String: String]? = nil) {
        self.command = command
        self.errorMessage = errorMessage
        self.responseTime = responseTime
        self.networkType = networkType
        self.batteryLevel = batteryLevel
        self.wifiSSID = wifiSSID
        self.additionalData = additionalData
    }
}

struct LogResponse: Codable {
    let success: Bool
    let message: String
    let logId: String?
    let timestamp: Date
}
