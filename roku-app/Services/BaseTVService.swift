//
//  BaseTVService.swift
//  roku-app
//
//  Created by Sengel on 8.09.2025.
//

import Foundation

enum TVServiceState {
    case connected
    case notConnected
    case pendingPermission
    case rejected
    case pinRequested
    case pinWrong
    case connectionFailed
}

protocol TVServicePinListener {
    func onPinRequested()
    func onPinWrong()
    func onPinAccepted()
}

class BaseTVService: NSObject, TVServiceProtocol {
    var device: TVDevice
    var isConnected: Bool = false
    weak var delegate: TVServiceDelegate?
    var tvServiceStateListener: ((TVServiceState, TVServicePinListener?) -> Void)?
    var storedConectedDevice: TVDevice?
    
    init(device: TVDevice) {
        self.device = device
    }
    
    func connect() async throws {
        throw TVServiceError.connectionFailed("Connection failed")
    }
    
    func disconnect() {
        isConnected = false
        delegate?.tvService(self, didDisconnect: device)
    }
    
    func sendCommand(_ command: TVRemoteCommand) async throws {
        throw TVServiceError.commandFailed("Command failed")
    }
    
    func discoverDevices() async throws -> [TVDevice] {
        return []
    }
    
    func testConnection() async throws -> Bool {
        return false
    }
    
    func didRequestPin(_ device: TVDevice) {
        AnalyticsManager.shared.fxAnalytics.send(event: "device_connect_request_pin", properties: [
            "device_type": device.brand.displayName,
            "device_name": device.name
        ])
        delegate?.tvService(self, didRequestPin: device)
    }
    
    func didDiscoverDevicesIncremental(_ devices: [TVDevice]) {
        delegate?.tvService(self, didDiscoverDevicesIncremental: devices)
    }
    
    
    func makeRequest(to url: URL, method: String = "POST", body: Data? = nil) async throws -> Data {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 3.0
        
        if let body = body {
            request.httpBody = body
        }
        
        print("📡 HTTP Request: \(method) \(url)")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ Invalid HTTP response")
            throw TVServiceError.networkError("Network request failed")
        }
        
        print("📊 HTTP Status: \(httpResponse.statusCode)")
        
        guard httpResponse.statusCode == 200 else {
            print("❌ HTTP Error: \(httpResponse.statusCode)")
            throw TVServiceError.connectionFailed("HTTP \(httpResponse.statusCode)")
        }
        
        print("✅ HTTP Response successful")
        return data
    }
    
    func scanNetworkForDevices(port: Int, timeout: TimeInterval = 2.0) async -> [String] {
        return []
    }
    
    func logConnectionAttempt() async {
        await LogService.shared.sendConnectionLog(
            device: device,
            status: .connecting,
            action: .connectionAttempt
        )
    }
    
    func logConnectionSuccess() async {
        await LogService.shared.sendConnectionLog(
            device: device,
            status: .connected,
            action: .connectionSuccess
        )
    }
    
    func logConnectionFailed(error: Error) async {
        let details = LogDetails(errorMessage: error.localizedDescription)
        await LogService.shared.sendConnectionLog(
            device: device,
            status: .failed,
            action: .connectionFailed,
            details: details
        )
    }
    
    func logCommandSent(command: String, success: Bool, responseTime: Double? = nil, error: Error? = nil) async {
        let errorMessage = error?.localizedDescription
        await LogService.shared.sendCommandLog(
            device: device,
            command: command,
            success: success,
            responseTime: responseTime,
            errorMessage: errorMessage
        )
    }
}
