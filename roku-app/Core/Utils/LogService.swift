//
//  LogService.swift
//  roku-app
//
//  Created by Ali İhsan Çağlayan on 8.09.2025.
//

import Foundation
import Alamofire
import Network

class LogService {
    static let shared = LogService()
    
    private let baseURL = "https://api.yourdomain.com/logs"
    private let session: Session
    private let networkMonitor = NWPathMonitor()
    private var currentNetworkType: String = "unknown"
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10
        configuration.timeoutIntervalForResource = 30
        
        session = Session(configuration: configuration)
        setupNetworkMonitoring()
    }
    
    private func setupNetworkMonitoring() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                if path.usesInterfaceType(.wifi) {
                    self?.currentNetworkType = "wifi"
                } else if path.usesInterfaceType(.cellular) {
                    self?.currentNetworkType = "cellular"
                } else if path.usesInterfaceType(.wiredEthernet) {
                    self?.currentNetworkType = "ethernet"
                } else {
                    self?.currentNetworkType = "unknown"
                }
            }
        }
        networkMonitor.start(queue: DispatchQueue.global(qos: .background))
    }
    
    func sendLog(_ log: TVLog) async {
        do {
            let response = try await session.request(
                baseURL,
                method: .post,
                parameters: log,
                encoder: JSONParameterEncoder.default
            ).serializingData().value
            
            let responseString = String(data: response, encoding: .utf8) ?? ""
            print("Log sent successfully, response: '\(responseString)' (length: \(response.count))")
        } catch {
            print("Failed to send log: \(error.localizedDescription)")
            await storeLogLocally(log)
        }
    }
    
    func sendConnectionLog(device: TVDevice, status: ConnectionStatus, action: LogAction, details: LogDetails? = nil) async {
        let deviceInfo = DeviceLogInfo(from: device)
        let log = TVLog(
            deviceInfo: deviceInfo,
            connectionStatus: status,
            action: action,
            details: details
        )
        
        await sendLog(log)
    }
    
    func sendCommandLog(device: TVDevice, command: String, success: Bool, responseTime: Double? = nil, errorMessage: String? = nil) async {
        let deviceInfo = DeviceLogInfo(from: device)
        let details = LogDetails(
            command: command,
            errorMessage: errorMessage,
            responseTime: responseTime,
            networkType: currentNetworkType,
            batteryLevel: getBatteryLevel(),
            wifiSSID: await getWifiSSID()
        )
        
        let log = TVLog(
            deviceInfo: deviceInfo,
            connectionStatus: device.isConnected ? .connected : .disconnected,
            action: success ? .commandSent : .commandFailed,
            details: details
        )
        
        await sendLog(log)
    }
    
    func sendAppLifecycleLog(action: LogAction) async {
        let dummyDevice = TVDevice(name: "App", brand: .roku, ipAddress: "0.0.0.0")
        let deviceInfo = DeviceLogInfo(from: dummyDevice)
        
        let details = LogDetails(
            networkType: currentNetworkType,
            batteryLevel: getBatteryLevel(),
            wifiSSID: await getWifiSSID()
        )
        
        let log = TVLog(
            deviceInfo: deviceInfo,
            connectionStatus: .unknown,
            action: action,
            details: details
        )
        
        await sendLog(log)
    }
    
    private func storeLogLocally(_ log: TVLog) async {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        if let data = try? encoder.encode(log) {
            UserDefaults.standard.set(data, forKey: "pending_logs_\(log.id)")
        }
    }
    
    func retryPendingLogs() async {
        let defaults = UserDefaults.standard
        let keys = defaults.dictionaryRepresentation().keys.filter { $0.hasPrefix("pending_logs_") }
        
        for key in keys {
            if let data = defaults.data(forKey: key) {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                
                if let log = try? decoder.decode(TVLog.self, from: data) {
                    await sendLog(log)
                    defaults.removeObject(forKey: key)
                }
            }
        }
    }
    
    private func getBatteryLevel() -> Float? {
        UIDevice.current.isBatteryMonitoringEnabled = true
        let batteryLevel = UIDevice.current.batteryLevel
        return batteryLevel >= 0 ? batteryLevel : nil
    }
    
    private func getWifiSSID() async -> String? {
        return nil
    }
}
