//
//  PhilipsTVService.swift
//  roku-app
//
//  Created by Ali İhsan Çağlayan on 8.09.2025.
//

import Foundation

class PhilipsTVService: BaseTVService {
    
    override init(device: TVDevice) {
        super.init(device: device)
    }
    
    
    override func connect() async throws {
        let url = URL(string: "\(device.connectionURL)/api/v1/")!
        
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
        
        let url = URL(string: "\(device.connectionURL)/api/v1/remote")!
        
        let commandData = try JSONSerialization.data(withJSONObject: [
            "key": command.command,
            "params": command.parameters ?? [:]
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
        let url = URL(string: "\(device.connectionURL)/api/v1/")!
        
        do {
            _ = try await makeRequest(to: url, method: "GET")
            return true
        } catch {
            return false
        }
    }
}
