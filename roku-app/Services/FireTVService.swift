//
//  FireTVService.swift
//  roku-app
//
//  Created by Ali İhsan Çağlayan on 8.09.2025.
//

import Foundation

class FireTVService: BaseTVService {
    
    override init(device: TVDevice) {
        super.init(device: device)
    }
    
    
    override func connect() async throws {
        let url = URL(string: "\(device.connectionURL)/")!
        
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
        
        let url = URL(string: "\(device.connectionURL)/command")!
        
        let commandData = try JSONSerialization.data(withJSONObject: [
            "command": command.command,
            "parameters": command.parameters ?? [:]
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
        let url = URL(string: "\(device.connectionURL)/")!
        
        do {
            _ = try await makeRequest(to: url, method: "GET")
            return true
        } catch {
            return false
        }
    }
}

extension FireTVService {
    static let fireTVCommands = [
        "Home": "HOME",
        "Back": "BACK",
        "Up": "DPAD_UP",
        "Down": "DPAD_DOWN",
        "Left": "DPAD_LEFT",
        "Right": "DPAD_RIGHT",
        "Select": "DPAD_CENTER",
        "Play": "MEDIA_PLAY",
        "Pause": "MEDIA_PAUSE",
        "Stop": "MEDIA_STOP",
        "Rewind": "MEDIA_REWIND",
        "FastForward": "MEDIA_FAST_FORWARD",
        "VolumeUp": "VOLUME_UP",
        "VolumeDown": "VOLUME_DOWN",
        "VolumeMute": "VOLUME_MUTE",
        "PowerOn": "POWER",
        "PowerOff": "POWER"
    ]
}
