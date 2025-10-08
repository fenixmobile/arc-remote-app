//
//  TVServiceProtocol.swift
//  roku-app
//
//  Created by Sengel on 8.09.2025.
//

import Foundation

protocol TVServiceProtocol {
    var device: TVDevice { get }
    var isConnected: Bool { get }
    
    func connect() async throws
    func disconnect()
    func sendCommand(_ command: TVRemoteCommand) async throws
    func discoverDevices() async throws -> [TVDevice]
    func testConnection() async throws -> Bool
}

protocol TVServiceDelegate: AnyObject {
    func tvService(_ service: TVServiceProtocol, didConnect device: TVDevice)
    func tvService(_ service: TVServiceProtocol, didDisconnect device: TVDevice)
    func tvService(_ service: TVServiceProtocol, didReceiveError error: Error)
    func tvService(_ service: TVServiceProtocol, didDiscoverDevices devices: [TVDevice])
    func tvService(_ service: TVServiceProtocol, didDiscoverDevicesIncremental devices: [TVDevice])
    func tvService(_ service: TVServiceProtocol, didRequestPin device: TVDevice)
}
