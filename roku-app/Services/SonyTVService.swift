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
            isConnected = false
            throw TVServiceError.connectionFailed("Sony TV connection failed: \(error.localizedDescription)")
        }
    }
    
    override func sendCommand(_ command: TVRemoteCommand) async throws {
        guard isConnected else {
            throw TVServiceError.connectionFailed("Sony TV not connected")
        }
        
        let mappedCommand = mapToSonyKeyCode(command.command)
        let url = URL(string: "\(device.connectionURL)/sony/ircc")!
        
        let commandData = try JSONSerialization.data(withJSONObject: [
            "id": 1,
            "method": "setIRCC",
            "params": [
                "IRCCCode": mappedCommand
            ]
        ])
        
        do {
            _ = try await makeRequest(to: url, method: "POST", body: commandData)
        } catch {
            throw TVServiceError.commandFailed("Sony TV command failed: \(error.localizedDescription)")
        }
    }
    
    private func mapToSonyKeyCode(_ command: String) -> String {
        switch command.lowercased() {
        case "power":
            return SonyTVService.sonyCommands["PowerOn"] ?? command
        case "home":
            return SonyTVService.sonyCommands["Home"] ?? command
        case "back":
            return SonyTVService.sonyCommands["Back"] ?? command
        case "up":
            return SonyTVService.sonyCommands["Up"] ?? command
        case "down":
            return SonyTVService.sonyCommands["Down"] ?? command
        case "left":
            return SonyTVService.sonyCommands["Left"] ?? command
        case "right":
            return SonyTVService.sonyCommands["Right"] ?? command
        case "select", "ok":
            return SonyTVService.sonyCommands["Select"] ?? command
        case "volumeup":
            return SonyTVService.sonyCommands["VolumeUp"] ?? command
        case "volumedown":
            return SonyTVService.sonyCommands["VolumeDown"] ?? command
        case "mute":
            return SonyTVService.sonyCommands["VolumeMute"] ?? command
        case "play":
            return SonyTVService.sonyCommands["Play"] ?? command
        case "pause":
            return SonyTVService.sonyCommands["Pause"] ?? command
        case "stop":
            return SonyTVService.sonyCommands["Stop"] ?? command
        case "rewind", "rev":
            return SonyTVService.sonyCommands["Rewind"] ?? command
        case "fastforward", "fwd":
            return SonyTVService.sonyCommands["FastForward"] ?? command
        case "playpause":
            return SonyTVService.sonyCommands["Play"] ?? command
        case "keyboard":
            return SonyTVService.sonyCommands["Keyboard"] ?? command
        case "backspace":
            return SonyTVService.sonyCommands["Backspace"] ?? command
        default:
            return command
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
    
    override func disconnect() {
        super.disconnect()
        isConnected = false
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
