//
//  LGTVService.swift
//  roku-app
//
//  Created by Ali İhsan Çağlayan on 8.09.2025.
//

import Foundation

class LGTVService: BaseTVService {
    
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
            isConnected = false
            throw TVServiceError.connectionFailed("LG TV connection failed: \(error.localizedDescription)")
        }
    }
    
    override func sendCommand(_ command: TVRemoteCommand) async throws {
        guard isConnected else {
            throw TVServiceError.connectionFailed("LG TV not connected")
        }
        
        let mappedCommand = mapToLGKeyCode(command.command)
        let url = URL(string: "\(device.connectionURL)/api/v2/channels/com.webos.service.tv/commands")!
        
        let commandData = try JSONSerialization.data(withJSONObject: [
            "method": "com.webos.service.tv.remote.sendKey",
            "params": [
                "key": mappedCommand
            ]
        ])
        
        do {
            _ = try await makeRequest(to: url, method: "POST", body: commandData)
        } catch {
            throw TVServiceError.commandFailed("LG TV command failed: \(error.localizedDescription)")
        }
    }
    
    private func mapToLGKeyCode(_ command: String) -> String {
        switch command.lowercased() {
        case "power":
            return "POWER"
        case "home":
            return "HOME"
        case "back":
            return "BACK"
        case "up":
            return "UP"
        case "down":
            return "DOWN"
        case "left":
            return "LEFT"
        case "right":
            return "RIGHT"
        case "select", "ok":
            return "ENTER"
        case "volumeup":
            return "VOLUMEUP"
        case "volumedown":
            return "VOLUMEDOWN"
        case "mute":
            return "MUTE"
        case "channelup":
            return "CHANNELUP"
        case "channeldown":
            return "CHANNELDOWN"
        case "play":
            return "PLAY"
        case "pause":
            return "PAUSE"
        case "stop":
            return "STOP"
        case "rewind", "rev":
            return "REWIND"
        case "fastforward", "fwd":
            return "FASTFORWARD"
        case "playpause":
            return "PLAY"
        case "input":
            return "INPUT"
        case "menu":
            return "MENU"
        case "info":
            return "INFO"
        case "exit":
            return "EXIT"
        case "netflix":
            return "NETFLIX"
        case "amazon":
            return "AMAZON"
        case "youtube":
            return "YOUTUBE"
        case "red":
            return "RED"
        case "green":
            return "GREEN"
        case "yellow":
            return "YELLOW"
        case "blue":
            return "BLUE"
        default:
            return command.uppercased()
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
    
    override func disconnect() {
        super.disconnect()
        isConnected = false
    }
}
