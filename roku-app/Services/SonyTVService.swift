//
//  SonyTVService.swift
//  roku-app
//
//  Created by Ali İhsan Çağlayan on 8.09.2025.
//

import Foundation

class SonyTVService: BaseTVService {
    
    override init(device: TVDevice) {
        super.init(device: device)
    }
    
    
    override func connect() async throws {
        let url = URL(string: "\(device.connectionURL)/sony/system")!
        
        do {
            _ = try await makeRequest(to: url, method: "GET")
            isConnected = true
            delegate?.tvService(self, didConnect: device)
        } catch {
            throw TVServiceError.connectionFailed("Connection failed")
        }
    }
    
    override func sendCommand(_ command: TVRemoteCommand) async throws {
        guard isConnected else {
            throw TVServiceError.connectionFailed("Connection failed")
        }
        
        let url = URL(string: "\(device.connectionURL)/sony/ircc")!
        
        let commandData = try JSONSerialization.data(withJSONObject: [
            "id": 1,
            "method": "setIRCC",
            "params": [
                "IRCCCode": command.command
            ]
        ])
        
        do {
            _ = try await makeRequest(to: url, method: "POST", body: commandData)
        } catch {
            throw TVServiceError.commandFailed("Command failed")
        }
    }
    
    override func discoverDevices() async throws -> [TVDevice] {
        return []
    }
    
    override func testConnection() async throws -> Bool {
        let url = URL(string: "\(device.connectionURL)/sony/system")!
        
        do {
            _ = try await makeRequest(to: url, method: "GET")
            return true
        } catch {
            return false
        }
    }
}

extension SonyTVService {
    static let sonyCommands = [
        "Home": "AAAAAQAAAAEAAABgAw==",
        "Back": "AAAAAgAAAJcAAABGAw==",
        "Up": "AAAAAQAAAAEAAABAAw==",
        "Down": "AAAAAQAAAAEAAABBAw==",
        "Left": "AAAAAQAAAAEAAAA8Aw==",
        "Right": "AAAAAQAAAAEAAAA9Aw==",
        "Select": "AAAAAQAAAAEAAABLAw==",
        "Play": "AAAAAQAAAAEAAAAaAw==",
        "Pause": "AAAAAQAAAAEAAAAZgw==",
        "Stop": "AAAAAQAAAAEAAAAYgw==",
        "VolumeUp": "AAAAAQAAAAEAAAASAw==",
        "VolumeDown": "AAAAAQAAAAEAAAATAw==",
        "VolumeMute": "AAAAAQAAAAEAAAAUAw==",
        "PowerOn": "AAAAAQAAAAEAAAAVAw==",
        "PowerOff": "AAAAAQAAAAEAAAAVAw==",
        "Keyboard": "AAAAAQAAAAEAAABLAw==",
        "Backspace": "AAAAAgAAAJcAAABGAw=="
    ]
}
