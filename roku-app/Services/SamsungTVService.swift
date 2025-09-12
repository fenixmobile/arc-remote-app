//
//  SamsungTVService.swift
//  roku-app
//
//  Created by Ali İhsan Çağlayan on 8.09.2025.
//

import Foundation
import Network

class SamsungTVService: BaseTVService, URLSessionWebSocketDelegate {
    private var webSocketTask: URLSessionWebSocketTask?
    private var urlSession: URLSession?
    private var pingTimer: Timer?
    
    override init(device: TVDevice) {
        super.init(device: device)
        urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
    }
    
    func setDeviceToken(_ token: String, deviceId: String) {
        UserDefaults.standard.setValue(token, forKey: "SamsungToken\(deviceId)")
    }
    
    func getDeviceToken(deviceId: String) -> String? {
        return UserDefaults.standard.string(forKey: "SamsungToken\(deviceId)")
    }
    
    var base64AppName: String {
        get {
            "ArcTVRemote".data(using: .utf8)?.base64EncodedString() ?? ""
        }
    }
    
    
    override func connect() async throws {
        print("🔍 Samsung TV WebSocket bağlantı denemesi başladı: \(device.ipAddress)")
        
        let existingToken = getDeviceToken(deviceId: device.id.uuidString)
        
        if let token = existingToken, !token.isEmpty {
            print("🔑 Mevcut token ile bağlantı kuruluyor: \(token)")
            try await connectWithToken(token)
        } else {
            print("🔑 Token yok, önce token alınıyor...")
            try await connectToGetToken()
        }
    }
    
    private func connectToGetToken() async throws {
        let ports = [8002, 8001, 8080, 55000]
        
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        
        for port in ports {
            let webSocketURL = createWebSocketURL(token: "", port: port)
            print("🌐 Samsung TV Token alma URL denemesi: \(webSocketURL)")
            
            do {
                var urlRequest = URLRequest(url: webSocketURL)
                urlRequest.networkServiceType = .responsiveData
                urlRequest.timeoutInterval = 30
                
                webSocketTask = urlSession?.webSocketTask(with: urlRequest)
                webSocketTask?.resume()
                
                try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                    var hasResumed = false
                    
                    let timeout = DispatchTime.now() + .seconds(30)
                    DispatchQueue.global().asyncAfter(deadline: timeout) {
                        guard !hasResumed else { return }
                        hasResumed = true
                        continuation.resume(throwing: TVServiceError.connectionFailed("WebSocket bağlantı timeout - kullanıcı izin vermedi"))
                    }
                    
                    webSocketTask?.receive { result in
                        guard !hasResumed else { return }
                        hasResumed = true
                        
                        switch result {
                        case .success(let message):
                            print("✅ Samsung TV WebSocket bağlantısı açıldı (token alma)")
                            self.device.port = port
                            self.handleWebSocketMessage(message)
                            continuation.resume()
                        case .failure(let error):
                            print("❌ Samsung TV WebSocket bağlantı hatası \(webSocketURL): \(error)")
                            continuation.resume(throwing: TVServiceError.connectionFailed("Samsung TV WebSocket'e bağlanılamadı"))
                        }
                    }
                }
                
                return
            } catch {
                print("❌ Samsung TV WebSocket bağlantı hatası port \(port): \(error)")
                continue
            }
        }
        
        throw TVServiceError.connectionFailed("Samsung TV WebSocket'e hiçbir portta bağlanılamadı")
    }
    
    private func connectWithToken(_ token: String) async throws {
        let webSocketURL = createWebSocketURL(token: token, port: device.port)
        print("🌐 Samsung TV Token ile bağlantı URL: \(webSocketURL)")
        
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        
        var urlRequest = URLRequest(url: webSocketURL)
        urlRequest.networkServiceType = .responsiveData
        urlRequest.timeoutInterval = 30
        
        webSocketTask = urlSession?.webSocketTask(with: urlRequest)
        webSocketTask?.resume()
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            var hasResumed = false
            
            let timeout = DispatchTime.now() + .seconds(30)
            DispatchQueue.global().asyncAfter(deadline: timeout) {
                guard !hasResumed else { return }
                hasResumed = true
                continuation.resume(throwing: TVServiceError.connectionFailed("WebSocket bağlantı timeout"))
            }
            
            webSocketTask?.receive { result in
                guard !hasResumed else { return }
                hasResumed = true
                
                switch result {
                case .success(let message):
                    print("✅ Samsung TV WebSocket bağlantısı başarılı (token ile)")
                    self.isConnected = true
                    self.delegate?.tvService(self, didConnect: self.device)
                    self.handleWebSocketMessage(message)
                    continuation.resume()
                case .failure(let error):
                    print("❌ Samsung TV WebSocket bağlantı hatası \(webSocketURL): \(error)")
                    continuation.resume(throwing: TVServiceError.connectionFailed("Samsung TV WebSocket'e bağlanılamadı"))
                }
            }
        }
        
        setPingTimer()
    }
    
    private func createWebSocketURL(token: String, port: Int) -> URL {
        var urlComponents = URLComponents()
        urlComponents.scheme = "wss"
        urlComponents.host = device.ipAddress
        urlComponents.port = port
        urlComponents.path = "/api/v2/channels/samsung.remote.control"
        
        urlComponents.queryItems = [
            URLQueryItem(name: "name", value: base64AppName),
            URLQueryItem(name: "token", value: token)
        ]
        
        return urlComponents.url!
    }
    
    override func sendCommand(_ command: TVRemoteCommand) async throws {
        guard isConnected else {
            throw TVServiceError.connectionFailed("Connection failed")
        }
        
        if webSocketTask?.state != .running {
            print("🔄 WebSocket bağlantısı kopmuş, yeniden bağlanıyor...")
            try await connect()
        }
        
        guard let webSocketTask = webSocketTask else {
            throw TVServiceError.connectionFailed("WebSocket bağlantısı yok")
        }
        
        let samsungCommand = mapToSamsungCommand(command.command)
        
        let commandData = [
            "method": "ms.remote.control",
            "params": [
                "Cmd": "Click",
                "DataOfCmd": samsungCommand,
                "Option": false,
                "TypeOfRemote": "SendRemoteKey"
            ]
        ] as [String : Any]
        
        print("🔍 Samsung TV komut gönderiliyor: \(commandData)")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: commandData)
            let jsonString = String(data: jsonData, encoding: .utf8) ?? ""
            
            print("📡 Samsung TV WebSocket komut gönderiliyor: \(command.command)")
            
            let message = URLSessionWebSocketTask.Message.string(jsonString)
            try await webSocketTask.send(message)
            
            print("✅ Samsung TV WebSocket komut başarılı: \(command.command)")
            
        } catch {
            print("❌ Samsung TV WebSocket komut hatası: \(error)")
            if error.localizedDescription.contains("Socket is not connected") {
                print("🔄 Socket hatası, yeniden bağlanıyor...")
                try await connect()
                try await sendCommand(command)
                return
            }
            throw error
        }
    }
    
    override func discoverDevices() async throws -> [TVDevice] {
        return []
    }
    
    private func mapToSamsungCommand(_ command: String) -> String {
        switch command.lowercased() {
        case "up":
            return "KEY_UP"
        case "down":
            return "KEY_DOWN"
        case "left":
            return "KEY_LEFT"
        case "right":
            return "KEY_RIGHT"
        case "select", "ok":
            return "KEY_ENTER"
        case "home":
            return "KEY_HOME"
        case "back":
            return "KEY_RETURN"
        case "play":
            return "KEY_PLAY"
        case "pause":
            return "KEY_PAUSE"
        case "stop":
            return "KEY_STOP"
        case "volumeup", "volume_up":
            return "KEY_VOLUP"
        case "volumedown", "volume_down":
            return "KEY_VOLDOWN"
        case "mute":
            return "KEY_MUTE"
        case "power":
            return "KEY_POWER"
        case "info":
            return "KEY_INFO"
        case "source":
            return "KEY_SOURCE"
        case "channelup", "channel_up":
            return "KEY_CHUP"
        case "channeldown", "channel_down":
            return "KEY_CHDOWN"
        case "rewind":
            return "KEY_REWIND"
        case "fastforward", "fast_forward":
            return "KEY_FF"
        default:
            return command
        }
    }
    
    override func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        pingTimer?.invalidate()
        pingTimer = nil
        isConnected = false
        print("🔌 Samsung TV WebSocket bağlantısı kapatıldı")
    }
    
    private func handleWebSocketMessage(_ message: URLSessionWebSocketTask.Message) {
        switch message {
        case .string(let messageStr):
            print("📨 Samsung TV WebSocket mesajı: \(messageStr)")
            handleSamsungResponse(messageStr)
        case .data(_):
            break
        @unknown default:
            break
        }
    }
    
    private func handleSamsungResponse(_ message: String) {
        guard let data = message.data(using: .utf8) else { return }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let event = json["event"] as? String {
                
                switch event {
                case "ms.channel.connect":
                    if let dataDict = json["data"] as? [String: Any],
                       let token = dataDict["token"] as? String {
                        print("🔑 Samsung TV token alındı: \(token)")
                        setDeviceToken(token, deviceId: device.id.uuidString)
                        
                        print("✅ Samsung TV izin verildi! Token ile yeniden bağlanıyor...")
                        
                        Task {
                            do {
                                try await connectWithToken(token)
                                print("✅ Samsung TV token ile bağlantı başarılı!")
                            } catch {
                                print("❌ Samsung TV token ile bağlantı hatası: \(error)")
                            }
                        }
                    }
                case "ms.channel.unauthorized":
                    print("❌ Samsung TV izni reddedildi")
                    DispatchQueue.main.async {
                        print("❌ Samsung TV izni reddedildi. Lütfen tekrar deneyin.")
                    }
                default:
                    break
                }
            }
        } catch {
            print("❌ Samsung TV response parse hatası: \(error)")
        }
    }
    
    override func testConnection() async throws -> Bool {
        let baseURL = "http://\(device.ipAddress):\(device.port)"
        let url = URL(string: "\(baseURL)/")!
        
        do {
            _ = try await makeRequest(to: url, method: "GET")
            return true
        } catch {
            return false
        }
    }
}

extension SamsungTVService {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("✅ Samsung TV WebSocket bağlantısı açıldı")
        
        let token = getDeviceToken(deviceId: device.id.uuidString)
        if token != nil {
            print("✅ Samsung TV token mevcut, bağlantı tamamlandı")
            isConnected = true
            delegate?.tvService(self, didConnect: device)
        } else {
            print("📱 Samsung TV token yok, izin popup'ı çıkmalı")
            DispatchQueue.main.async {
                print("📱 Samsung TV'de izin popup'ı çıkmalı! Lütfen TV'de 'İzin Ver' butonuna basın.")
            }
        }
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("❌ Samsung TV WebSocket bağlantısı kapandı")
        isConnected = false
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        
        let credential = URLCredential(trust: serverTrust)
        completionHandler(.useCredential, credential)
    }
}

extension SamsungTVService {
    private func setPingTimer() {
        DispatchQueue.main.async {
            self.pingTimer?.invalidate()
            self.pingTimer = Timer.scheduledTimer(timeInterval: 9.0,
                                                  target: self,
                                                  selector: #selector(self.ping),
                                                  userInfo: nil,
                                                  repeats: true)
            self.pingTimer?.fire()
        }
    }
    
    @objc private func ping() {
        webSocketTask?.sendPing { [weak self] error in
            if let error = error {
                print("❌ Samsung TV ping hatası: \(error)")
                self?.reconnect()
            }
        }
    }
    
    private func reconnect() {
        Task {
            do {
                try await connect()
            } catch {
                print("❌ Samsung TV yeniden bağlantı hatası: \(error)")
            }
        }
    }
}

extension SamsungTVService {
    static let samsungCommands = [
        "Home": "KEY_HOME",
        "Back": "KEY_RETURN",
        "Up": "KEY_UP",
        "Down": "KEY_DOWN",
        "Left": "KEY_LEFT",
        "Right": "KEY_RIGHT",
        "Select": "KEY_ENTER",
        "Play": "KEY_PLAY",
        "Pause": "KEY_PAUSE",
        "Stop": "KEY_STOP",
        "Rewind": "KEY_REWIND",
        "FastForward": "KEY_FF",
        "VolumeUp": "KEY_VOLUP",
        "VolumeDown": "KEY_VOLDOWN",
        "VolumeMute": "KEY_MUTE",
        "PowerOn": "KEY_POWERON",
        "PowerOff": "KEY_POWEROFF"
    ]
}
