//
//  ToshibaTVService.swift
//  roku-app
//
//  Created by Ali İhsan Çağlayan on 8.09.2025.
//

import Foundation

class ToshibaTVService: BaseTVService {
    
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
            throw TVServiceError.connectionFailed("Toshiba TV connection failed: \(error.localizedDescription)")
        }
    }
    
    override func sendCommand(_ command: TVRemoteCommand) async throws {
        guard isConnected else {
            throw TVServiceError.connectionFailed("Toshiba TV not connected")
        }
        
        let mappedCommand = mapToToshibaKeyCode(command.command)
        let url = URL(string: "\(device.connectionURL)/command")!
        
        let commandData = try JSONSerialization.data(withJSONObject: [
            "command": mappedCommand,
            "parameters": command.parameters ?? [:]
        ])
        
        do {
            _ = try await makeRequest(to: url, method: "POST", body: commandData)
        } catch {
            throw TVServiceError.commandFailed("Toshiba TV command failed: \(error.localizedDescription)")
        }
    }
    
    private func mapToToshibaKeyCode(_ command: String) -> String {
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
            return "OK"
        case "volumeup":
            return "VOLUME_UP"
        case "volumedown":
            return "VOLUME_DOWN"
        case "mute":
            return "MUTE"
        case "channelup":
            return "CHANNEL_UP"
        case "channeldown":
            return "CHANNEL_DOWN"
        case "play":
            return "PLAY"
        case "pause":
            return "PAUSE"
        case "stop":
            return "STOP"
        case "rewind", "rev":
            return "REWIND"
        case "fastforward", "fwd":
            return "FAST_FORWARD"
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
