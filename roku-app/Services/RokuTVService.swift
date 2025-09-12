//
//  RokuTVService.swift
//  roku-app
//
//  Created by Ali İhsan Çağlayan on 8.09.2025.
//

import Foundation
import Alamofire

class RokuTVService: BaseTVService {
    
    override init(device: TVDevice) {
        super.init(device: device)
    }
    
    
    override func connect() async throws {
        print("🔍 Roku TV bağlantı denemesi başladı: \(device.ipAddress)")
        await logConnectionAttempt()
        
        let ports = [8060, 8080, 8081, 8082]
        let endpoints = ["/query/device-info", "/query/apps", "/query/active-app", "/"]
        
        for port in ports {
            for endpoint in endpoints {
                let url = URL(string: "http://\(device.ipAddress):\(port)\(endpoint)")!
                print("🌐 Roku TV URL: \(url)")
                
                do {
                    let data = try await makeRequest(to: url, method: "GET")
                    let responseString = String(data: data, encoding: .utf8) ?? "No text response"
                    print("📄 Roku TV Response: \(responseString)")
                    
                    if !responseString.isEmpty && responseString != "No text response" {
                        print("✅ Roku TV bağlantı başarılı: \(url)")
                        isConnected = true
                        device.port = port
                        delegate?.tvService(self, didConnect: device)
                        await logConnectionSuccess()
                        return
                    } else {
                        print("❌ Roku TV boş response: \(url)")
                        continue
                    }
                } catch {
                    print("❌ Roku TV bağlantı hatası \(url): \(error)")
                    continue
                }
            }
        }
        
        print("🚫 Tüm Roku TV bağlantı denemeleri başarısız")
        let error = TVServiceError.connectionFailed("Roku TV'ye bağlanılamadı. TV açık mı? Doğru IP adresi mi? Developer Mode açık mı?")
        await logConnectionFailed(error: error)
        throw error
    }
    
    override func sendCommand(_ command: TVRemoteCommand) async throws {
        guard isConnected else {
            let error = TVServiceError.connectionFailed("Connection failed")
            await logCommandSent(command: command.command, success: false, error: error)
            throw TVServiceError.commandFailed("Command failed")
        }
        
        let url = URL(string: "http://\(device.ipAddress):\(device.port)/keypress/\(command.command)")!
        print("🎮 Roku TV komut gönderiliyor: \(url)")
        let startTime = Date()
        
        do {
            let data = try await makeRokuRequest(to: url, method: "POST")
            let responseString = String(data: data, encoding: .utf8) ?? ""
            print("📄 Roku TV komut response: '\(responseString)' (length: \(data.count))")
            
            let responseTime = Date().timeIntervalSince(startTime)
            print("✅ Roku TV komut başarılı: \(command.command)")
            await logCommandSent(command: command.command, success: true, responseTime: responseTime)
        } catch {
            let responseTime = Date().timeIntervalSince(startTime)
            print("❌ Roku TV komut hatası: \(command.command) - \(error)")
            await logCommandSent(command: command.command, success: false, responseTime: responseTime, error: error)
            throw TVServiceError.commandFailed("Roku TV komut gönderilemedi: \(error.localizedDescription)")
        }
    }
    
    override func discoverDevices() async throws -> [TVDevice] {
        return []
    }
    
    override func testConnection() async throws -> Bool {
        let url = URL(string: "http://\(device.ipAddress):\(device.port)/query/device-info")!
        print("🔍 Roku TV bağlantı testi: \(url)")
        
        do {
            _ = try await makeRequest(to: url, method: "GET")
            print("✅ Roku TV bağlantı testi başarılı")
            return true
        } catch {
            print("❌ Roku TV bağlantı testi başarısız: \(error)")
            return false
        }
    }
    
    // Roku TV komutları için özel HTTP isteği method'u (URLSession ile - proxy bypass)
    private func makeRokuRequest(to url: URL, method: String = "POST", body: Data? = nil) async throws -> Data {
        print("📡 Roku HTTP Request: \(method) \(url)")
        
        // Özel URLSession configuration - proxy bypass için
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 3.0
        config.timeoutIntervalForResource = 5.0
        config.httpShouldUsePipelining = false
        config.httpMaximumConnectionsPerHost = 1
        config.connectionProxyDictionary = [:] // Proxy'yi bypass et
        
        let session = URLSession(configuration: config)
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        urlRequest.timeoutInterval = 3.0
        urlRequest.setValue("roku-app/1.0", forHTTPHeaderField: "User-Agent")
        urlRequest.setValue("close", forHTTPHeaderField: "Connection")
        
        if let body = body {
            urlRequest.httpBody = body
        }
        
        do {
            let (data, response) = try await session.data(for: urlRequest)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📊 Roku HTTP Status: \(httpResponse.statusCode)")
                print("📄 Roku HTTP Headers: \(httpResponse.allHeaderFields)")
                
                if httpResponse.statusCode == 200 {
                    print("📄 Roku TV Response: '\(String(data: data, encoding: .utf8) ?? "")' (length: \(data.count))")
                    return data
                } else {
                    throw TVServiceError.connectionFailed("HTTP \(httpResponse.statusCode)")
                }
            } else {
                throw TVServiceError.connectionFailed("Invalid HTTP response")
            }
        } catch {
            print("❌ Roku HTTP Error: \(error.localizedDescription)")
            throw TVServiceError.connectionFailed("Roku HTTP Error: \(error.localizedDescription)")
        }
    }
}

extension RokuTVService {
    static let rokuCommands = [
        "Home": "Home",
        "Back": "Back",
        "Up": "Up",
        "Down": "Down",
        "Left": "Left",
        "Right": "Right",
        "Select": "Select",
        "Play": "Play",
        "Pause": "Pause",
        "Stop": "Stop",
        "Rewind": "Rev",
        "FastForward": "Fwd",
        "VolumeUp": "VolumeUp",
        "VolumeDown": "VolumeDown",
        "VolumeMute": "VolumeMute",
        "PowerOn": "PowerOn",
        "PowerOff": "PowerOff"
    ]
}
