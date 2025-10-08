//
//  TVDevice.swift
//  roku-app
//
//  Created by Sengel on 8.09.2025.
//

import Foundation

struct TVDevice: Identifiable, Codable {
    let id: UUID
    let name: String
    let brand: TVBrand
    let ipAddress: String
    var port: Int
    let isConnected: Bool
    let lastConnected: Date?
    let customName: String?
    
    init(name: String, brand: TVBrand, ipAddress: String, port: Int = 8080, customName: String? = nil) {
        self.id = UUID()
        self.name = name
        self.brand = brand
        self.ipAddress = ipAddress
        self.port = port
        self.isConnected = false
        self.lastConnected = nil
        self.customName = customName
    }
    
    var displayName: String {
        return customName ?? name
    }
    
    var connectionURL: String {
        return "http://\(ipAddress):\(port)"
    }
}

struct TVRemoteCommand: Codable {
    let command: String
    let parameters: [String: Any]?
    
    enum CodingKeys: String, CodingKey {
        case command
        case parameters
    }
    
    init(command: String, parameters: [String: Any]? = nil) {
        self.command = command
        self.parameters = parameters
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        command = try container.decode(String.self, forKey: .command)
        parameters = try container.decodeIfPresent([String: String].self, forKey: .parameters)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(command, forKey: .command)
        if let parameters = parameters {
            try container.encode(parameters as? [String: String], forKey: .parameters)
        }
    }
}
