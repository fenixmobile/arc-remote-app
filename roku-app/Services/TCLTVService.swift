//
//  TCLTVService.swift
//  roku-app
//
//  Created by Sengel on 8.09.2025.
//

import Foundation

class TCLTVService: BaseTVService {
    
    override init(device: TVDevice) {
        super.init(device: device)
    }
    
    
    override func connect() async throws {
        let url = URL(string: "\(device.connectionURL)/query/device-info")!
        
        do {
            _ = try await makeRequest(to: url, method: "GET")
            isConnected = true
            delegate?.tvService(self, didConnect: device)
        } catch {
            isConnected = false
            throw TVServiceError.connectionFailed("TCL TV connection failed: \(error.localizedDescription)")
        }
    }
    
    override func sendCommand(_ command: TVRemoteCommand) async throws {
        guard isConnected else {
            throw TVServiceError.connectionFailed("TCL TV not connected")
        }
        
        let mappedCommand = mapToTCLKeyCode(command.command)
        let url = URL(string: "\(device.connectionURL)/keypress/\(mappedCommand)")!
        
        do {
            _ = try await makeRequest(to: url, method: "POST")
        } catch {
            throw TVServiceError.commandFailed("TCL TV command failed: \(error.localizedDescription)")
        }
    }
    
    private func mapToTCLKeyCode(_ command: String) -> String {
        switch command.lowercased() {
        case "power":
            return "Power"
        case "home":
            return "Home"
        case "back":
            return "Back"
        case "up":
            return "Up"
        case "down":
            return "Down"
        case "left":
            return "Left"
        case "right":
            return "Right"
        case "select", "ok":
            return "Select"
        case "volumeup":
            return "VolumeUp"
        case "volumedown":
            return "VolumeDown"
        case "mute":
            return "Mute"
        case "channelup":
            return "ChannelUp"
        case "channeldown":
            return "ChannelDown"
        case "play":
            return "Play"
        case "pause":
            return "Pause"
        case "stop":
            return "Stop"
        case "rewind", "rev":
            return "Rewind"
        case "fastforward", "fwd":
            return "FastForward"
        case "playpause":
            return "Play"
        case "input":
            return "Input"
        case "menu":
            return "Menu"
        case "info":
            return "Info"
        case "exit":
            return "Exit"
        default:
            return command
        }
    }
    
    override func discoverDevices() async throws -> [TVDevice] {
        return []
    }
    
    override func testConnection() async throws -> Bool {
        let url = URL(string: "\(device.connectionURL)/query/device-info")!
        
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
