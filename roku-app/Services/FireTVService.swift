//
//  FireTVService.swift
//  roku-app
//
//  Created by Ali İhsan Çağlayan on 8.09.2025.
//

import Foundation
import UIKit

class FireTVService: BaseTVService, URLSessionDelegate {
    
    private var fireTVToken: String?
    private let fireTVApiKey = "0987654321"
    private let appName = "Universal Remote"
    private lazy var urlSession: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10.0
        config.timeoutIntervalForResource = 30.0
        return URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue())
    }()
    
    override init(device: TVDevice) {
        super.init(device: device)
        delegate = TVServiceManager.shared
    }
    
    override func connect() async throws {
        print("🔍 FireTV bağlantı başlatılıyor: \(device.ipAddress)")
        await logConnectionAttempt()
        
        do {
            print("📡 FireTV HTTP bağlantı testi yapılıyor...")
            
            try await requestOpener()
            
            if let token = getDeviceToken(deviceId: device.id.uuidString) {
                fireTVToken = token
                print("✅ FireTV token ile bağlantı başarılı")
                isConnected = true
                delegate?.tvService(self, didConnect: device)
                await logConnectionSuccess()
            } else {
                print("🔐 FireTV PIN doğrulama gerekiyor")
                try await requestPINVerification()
            }
            
        } catch {
            print("❌ FireTV bağlantı hatası: \(error)")
            isConnected = false
            delegate?.tvService(self, didReceiveError: error)
            throw error
        }
    }
    
    override func sendCommand(_ command: TVRemoteCommand) async throws {
        guard isConnected else {
            let error = TVServiceError.connectionFailed("Connection failed")
            await logCommandSent(command: command.command, success: false, error: error)
            throw TVServiceError.commandFailed("Command failed")
        }
        
        let fireTVCommand = mapToFireTVCommand(command.command)
        
        print("🎮 FireTV komut gönderiliyor: \(command.command) -> \(fireTVCommand)")
        
        let startTime = Date()
        
        do {
            _ = try await executeFireTVCommand(fireTVCommand, withText: command.command == "Keyboard" ? command.parameters?["text"] as? String : nil)
            let responseTime = Date().timeIntervalSince(startTime)
            
            print("✅ FireTV komut başarılı: \(command.command)")
            await logCommandSent(command: command.command, success: true, responseTime: responseTime)
        } catch {
            let responseTime = Date().timeIntervalSince(startTime)
            print("❌ FireTV komut hatası: \(command.command) - \(error)")
            await logCommandSent(command: command.command, success: false, responseTime: responseTime, error: error)
            throw error
        }
    }
    
    override func discoverDevices() async throws -> [TVDevice] {
        var discoveredDevices: [TVDevice] = []
        
        let testIPs = ["10.34.35.10", "192.168.1.100", "192.168.0.100"]
        
        for ip in testIPs {
            let testDevice = TVDevice(
                name: "FireTV Device",
                brand: .fireTV,
                ipAddress: ip,
                port: 8080
            )
            discoveredDevices.append(testDevice)
        }
        
        return discoveredDevices
    }
    
    private func requestOpener() async throws {
        guard let url = URL(string: "http://\(device.ipAddress):8009/apps/FireTVRemote") else {
            throw TVServiceError.connectionFailed("Invalid URL")
        }
        
        print("📡 FireTV opener request: \(url)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.setValue(fireTVApiKey, forHTTPHeaderField: "X-Api-Key")
        
        let (_, response) = try await urlSession.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("📊 FireTV opener response: \(httpResponse.statusCode)")
            if httpResponse.statusCode != 200 && httpResponse.statusCode != 201 {
                throw TVServiceError.connectionFailed("Opener request failed with status: \(httpResponse.statusCode)")
            }
        }
        
        try await Task.sleep(nanoseconds: 500_000_000)
    }
    
    private func requestPINVerification() async throws {
        guard let url = URL(string: "https://\(device.ipAddress):8080/v1/FireTV/pin/display") else {
            throw TVServiceError.connectionFailed("Invalid PIN URL")
        }
        
        print("🔐 FireTV PIN request: \(url)")
        
        let pinRequest = FireTVPinDisplayRequestDTO(friendlyName: appName)
        let jsonData = try JSONEncoder().encode(pinRequest)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.setValue(fireTVApiKey, forHTTPHeaderField: "X-Api-Key")
        request.httpBody = jsonData
        
        let (data, response) = try await urlSession.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("📊 FireTV PIN response: \(httpResponse.statusCode)")
            if httpResponse.statusCode != 200 && httpResponse.statusCode != 201 {
                throw TVServiceError.connectionFailed("PIN request failed with status: \(httpResponse.statusCode)")
            }
        }
        
        let pinResponse = try JSONDecoder().decode(FireTVResponseDTO.self, from: data)
        print("📄 FireTV PIN response: \(pinResponse.description)")
        
        if pinResponse.description.lowercased() == "ok" {
            print("🔐 PIN kodu FireTV ekranında görünüyor")
            
            await withCheckedContinuation { continuation in
                Task { @MainActor in
                    await self.requestPINFromUser(continuation: continuation)
                }
            }
        } else {
            throw TVServiceError.connectionFailed("PIN request failed")
        }
    }
    
    private func verifyPIN(_ pin: String) async throws -> Bool {
        guard let url = URL(string: "https://\(device.ipAddress):8080/v1/FireTV/pin/verify") else {
            throw TVServiceError.connectionFailed("Invalid PIN verify URL")
        }
        
        print("🔐 FireTV PIN verify: \(url)")
        
        let pinVerify = FireTVPinVerifyRequestDTO(pin: pin)
        let jsonData = try JSONEncoder().encode(pinVerify)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.setValue(fireTVApiKey, forHTTPHeaderField: "X-Api-Key")
        request.httpBody = jsonData
        
        let (data, response) = try await urlSession.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("📊 FireTV PIN verify response: \(httpResponse.statusCode)")
            if httpResponse.statusCode != 200 && httpResponse.statusCode != 201 {
                return false
            }
        }
        
        let verifyResponse = try JSONDecoder().decode(FireTVResponseDTO.self, from: data)
        print("📄 FireTV PIN verify response: \(verifyResponse.description)")
        
        if !verifyResponse.description.isEmpty {
            fireTVToken = verifyResponse.description
            setDeviceToken(verifyResponse.description, deviceId: device.id.uuidString)
            print("✅ FireTV PIN doğrulama başarılı, token: \(verifyResponse.description)")
            return true
        } else {
            print("❌ FireTV PIN doğrulama başarısız")
            return false
        }
    }
    
    private func executeFireTVCommand(_ command: String, withText text: String? = nil) async throws -> String {
        guard let fireTVToken = fireTVToken else {
            throw TVServiceError.commandFailed("No authentication token")
        }
        
        guard let url = URL(string: "https://\(device.ipAddress):8080/v1/\(command)") else {
            throw TVServiceError.commandFailed("Invalid command URL")
        }
        
        print("📡 FireTV HTTP komut gönderiliyor: \(command) on port 8080")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.setValue(fireTVApiKey, forHTTPHeaderField: "X-Api-Key")
        request.setValue(fireTVToken, forHTTPHeaderField: "x-client-token")
        
        if command.contains("voiceCommand") {
            let voiceCommand = FireTVVoiceCommandRequestDTO(action: "Start")
            let jsonData = try JSONEncoder().encode(voiceCommand)
            request.httpBody = jsonData
            print("🎤 Alexa voice command parametresi gönderiliyor: Start")
        } else if command.contains("text") {
            let textToSend = text ?? "text"
            let textCommand = FireTVTextRequestDTO(text: textToSend)
            let jsonData = try JSONEncoder().encode(textCommand)
            request.httpBody = jsonData
            print("⌨️ Keyboard text parametresi gönderiliyor: \(textToSend)")
        }
        
        let (data, response) = try await urlSession.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("📊 FireTV HTTP Status: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                let responseString = String(data: data, encoding: .utf8) ?? ""
                print("📄 FireTV HTTP response: \(responseString)")
                return responseString
            } else {
                throw TVServiceError.commandFailed("HTTP command failed with status: \(httpResponse.statusCode)")
            }
        } else {
            throw TVServiceError.commandFailed("Invalid HTTP response")
        }
    }
    
    private func setDeviceToken(_ token: String, deviceId: String) {
        UserDefaults.standard.setValue(token, forKey: "FireTVToken\(deviceId)")
    }
    
    private func getDeviceToken(deviceId: String) -> String? {
        return UserDefaults.standard.string(forKey: "FireTVToken\(deviceId)")
    }
    
    private func mapToFireTVCommand(_ command: String) -> String {
        switch command.lowercased() {
        case "home":
            return "FireTV?action=home"
        case "back":
            return "FireTV?action=back"
        case "up":
            return "FireTV?action=dpad_up"
        case "down":
            return "FireTV?action=dpad_down"
        case "left":
            return "FireTV?action=dpad_left"
        case "right":
            return "FireTV?action=dpad_right"
        case "ok":
            return "FireTV?action=select"
        case "select":
            return "FireTV?action=select"
        case "play":
            return "media?action=play"
        case "pause":
            return "media?action=pause"
        case "stop":
            return "media?action=stop"
        case "rewind":
            return "FireTV?action=dpad_left"
        case "fastforward":
            return "FireTV?action=dpad_right"
        case "volumeup":
            return "FireTV?action=volume_up"
        case "volumedown":
            return "FireTV?action=volume_down"
        case "volumemute":
            return "FireTV?action=mute"
        case "poweron":
            return "FireTV?action=wake"
        case "poweroff":
            return "FireTV?action=sleep"
        case "menu":
            return "FireTV?action=menu"
        case "youtube":
            return "FireTV/app/com.amazon.firetv.youtube"
        case "netflix":
            return "FireTV/app/com.netflix.ninja"
        case "spotify":
            return "FireTV/app/com.spotify.tv.android"
        case "alexa":
            return "FireTV/voiceCommand?action=start"
        case "keyboard":
            return "FireTV/text"
        case "backspace":
            return "FireTV?action=backspace"
        default:
            return "FireTV?action=home"
        }
    }
}

extension FireTVService {
    static let fireTVCommands = [
        "Home": "FireTV?action=home",
        "Back": "FireTV?action=back",
        "Up": "FireTV?action=dpad_up",
        "Down": "FireTV?action=dpad_down",
        "Left": "FireTV?action=dpad_left",
        "Right": "FireTV?action=dpad_right",
        "Select": "FireTV?action=select",
        "Play": "media?action=play",
        "Pause": "media?action=pause",
        "Stop": "media?action=stop",
        "Rewind": "FireTV?action=dpad_left",
        "FastForward": "FireTV?action=dpad_right",
        "VolumeUp": "FireTV?action=volume_up",
        "VolumeDown": "FireTV?action=volume_down",
        "VolumeMute": "FireTV?action=mute",
        "PowerOn": "FireTV?action=wake",
        "PowerOff": "FireTV?action=sleep",
        "Menu": "FireTV?action=menu",
        "YouTube": "FireTV/app/com.amazon.firetv.youtube",
        "Netflix": "FireTV/app/com.netflix.ninja",
        "Spotify": "FireTV/app/com.spotify.tv.android",
        "Alexa": "FireTV/voiceCommand?action=start",
        "Keyboard": "FireTV/text",
        "Backspace": "FireTV?action=backspace"
    ]
    
    private func requestPINFromUser(continuation: CheckedContinuation<Void, Never>) async {
        await MainActor.run {
            let alert = UIAlertController(
                title: "FireTV PIN Girişi",
                message: "FireTV ekranında görünen PIN kodunu girin:",
                preferredStyle: .alert
            )
            
            alert.addTextField { textField in
                textField.placeholder = "PIN kodu"
                textField.keyboardType = .numberPad
                textField.isSecureTextEntry = false
            }
            
            let submitAction = UIAlertAction(title: "Bağlan", style: .default) { [weak self] _ in
                guard let self = self,
                      let pinText = alert.textFields?.first?.text,
                      !pinText.isEmpty else {
                    print("❌ PIN kodu boş")
                    continuation.resume()
                    return
                }
                
                Task {
                    do {
                        let success = try await self.verifyPIN(pinText)
                        if success {
                            print("✅ FireTV bağlantısı başarılı!")
                            self.isConnected = true
                            self.delegate?.tvService(self, didConnect: self.device)
                            await self.logConnectionSuccess()
                            continuation.resume()
                        } else {
                            print("❌ PIN doğrulama başarısız")
                            continuation.resume()
                        }
                    } catch {
                        print("❌ PIN doğrulama hatası: \(error)")
                        continuation.resume()
                    }
                }
            }
            
            let cancelAction = UIAlertAction(title: "İptal", style: .cancel) { [weak self] _ in
                print("❌ PIN girişi iptal edildi")
                self?.delegate?.tvService(self!, didReceiveError: TVServiceError.connectionFailed("PIN girişi iptal edildi"))
                continuation.resume()
            }
            
            alert.addAction(submitAction)
            alert.addAction(cancelAction)
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootViewController = window.rootViewController {
                var topController = rootViewController
                while let presentedController = topController.presentedViewController {
                    topController = presentedController
                }
                topController.present(alert, animated: true)
            }
        }
    }
}

extension FireTVService {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        print("🔐 SSL Challenge received for: \(challenge.protectionSpace.host)")
        
        if challenge.protectionSpace.serverTrust == nil {
            print("⚠️ No server trust available")
            completionHandler(.useCredential, nil)
        } else {
            let trust = challenge.protectionSpace.serverTrust!
            let credential = URLCredential(trust: trust)
            print("✅ Accepting self-signed certificate for FireTV")
            completionHandler(.useCredential, credential)
        }
    }
}