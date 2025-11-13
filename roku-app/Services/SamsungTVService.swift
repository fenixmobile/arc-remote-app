//
//  SamsungTVService.swift
//  roku-app
//
//  Created by Sengel on 8.09.2025.
//

import Foundation
import Network

class SamsungTVService: BaseTVService, URLSessionWebSocketDelegate {
    private(set) var webSocketTask: URLSessionWebSocketTask?
    private var urlSession: URLSession?
    private var pingTimer: Timer?
    private var connectionContinuation: CheckedContinuation<Void, Error>?
    private var isAuthorizationRejected = false
    private var currentConnectionId: UUID?
    
    override init(device: TVDevice) {
        super.init(device: device)
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 60
        config.timeoutIntervalForResource = 120
        
        config.urlCredentialStorage = nil
        config.httpCookieStorage = nil
        
        urlSession = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue())
        
        delegate = TVServiceManager.shared
        print("🔗 SamsungTVService: delegate TVServiceManager'a set edildi")
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
        
        if isConnected, let webSocketTask = webSocketTask, webSocketTask.state == .running {
            print("✅ Samsung TV zaten bağlı, yeniden bağlanmaya gerek yok")
            return
        }
        
        isConnected = false
        isAuthorizationRejected = false
        
        let existingToken = getDeviceToken(deviceId: device.id.uuidString)
        
        if let token = existingToken, !token.isEmpty {
            print("🔑 Mevcut token ile bağlantı kuruluyor: \(token)")
            do {
                try await connectWithToken(token)
                return
            } catch {
                print("❌ Token ile bağlantı başarısız, token'ı temizleyip yeniden deniyor: \(error)")
                isConnected = false
                setDeviceToken("", deviceId: device.id.uuidString)
            }
        }
        
        print("🔑 Token yok veya geçersiz, önce token alınıyor...")
        try await connectToGetToken()
    }
    
    private func connectToGetToken() async throws {
        print("🔍 Samsung TV Token alma süreci başladı: \(device.ipAddress)")
        print("📱 Base64 App Name: \(base64AppName)")
        
        try await wakeUpSamsungTV()
        
        let ports = [8002, 8001, 8080, 55000]
        
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        
        var lastError: Error?
        
        for port in ports {
            print("🌐 Samsung TV Port \(port) için WebSocket bağlantısı kuruluyor...")
            
            let webSocketURL = createWebSocketURL(token: "", port: port)
            print("🌐 Samsung TV Token alma URL denemesi: \(webSocketURL)")
            
            do {
                var urlRequest = URLRequest(url: webSocketURL)
                urlRequest.networkServiceType = .responsiveData
                urlRequest.timeoutInterval = 60
                
                let currentWebSocketTask = urlSession?.webSocketTask(with: urlRequest)
                currentWebSocketTask?.resume()
                
                print("📱 Samsung TV WebSocket bağlantısı başlatıldı. TV'de izin popup'ı çıkmalı!")
                
                try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                    var hasResumed = false
                    var timeoutWorkItem: DispatchWorkItem?
                    let connectionId = UUID()
                    
                    self.connectionContinuation = continuation
                    self.currentConnectionId = connectionId
                    
                    timeoutWorkItem = DispatchWorkItem {
                        guard !hasResumed, self.currentConnectionId == connectionId else { return }
                        hasResumed = true
                        self.connectionContinuation = nil
                        self.currentConnectionId = nil
                        print("⏰ Samsung TV WebSocket bağlantı timeout - port \(port)")
                        continuation.resume(throwing: TVServiceError.connectionFailed("WebSocket bağlantı timeout - kullanıcı izin vermedi"))
                    }
                    
                    DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(60), execute: timeoutWorkItem!)
                    
                    currentWebSocketTask?.receive { result in
                        guard !hasResumed, self.currentConnectionId == connectionId else { return }
                        timeoutWorkItem?.cancel()
                        
                        switch result {
                        case .success(let message):
                            print("✅ Samsung TV WebSocket bağlantısı açıldı (token alma) - port \(port)")
                            self.device.port = port
                            self.webSocketTask = currentWebSocketTask
                            self.handleWebSocketMessage(message)
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                guard !hasResumed, self.currentConnectionId == connectionId else { return }
                                
                                if self.isAuthorizationRejected {
                                    hasResumed = true
                                    self.connectionContinuation = nil
                                    self.currentConnectionId = nil
                                    continuation.resume(throwing: TVServiceError.connectionFailed("Samsung TV izni reddedildi"))
                                } else if self.isConnected {
                                    hasResumed = true
                                    self.connectionContinuation = nil
                                    self.currentConnectionId = nil
                                    continuation.resume()
                                } else {
                                    let tokenReceived = self.getDeviceToken(deviceId: self.device.id.uuidString) != nil
                                    if tokenReceived {
                                        hasResumed = true
                                        self.connectionContinuation = nil
                                        self.currentConnectionId = nil
                                        continuation.resume()
                                    } else {
                                        hasResumed = true
                                        self.connectionContinuation = nil
                                        self.currentConnectionId = nil
                                        continuation.resume(throwing: TVServiceError.connectionFailed("Samsung TV bağlantı doğrulanamadı"))
                                    }
                                }
                            }
                        case .failure(let error):
                            guard !hasResumed, self.currentConnectionId == connectionId else { return }
                            hasResumed = true
                            timeoutWorkItem?.cancel()
                            self.connectionContinuation = nil
                            self.currentConnectionId = nil
                            print("❌ Samsung TV WebSocket bağlantı hatası port \(port) \(webSocketURL): \(error)")
                            continuation.resume(throwing: TVServiceError.connectionFailed("Samsung TV WebSocket'e bağlanılamadı"))
                        }
                    }
                }
                
                return
            } catch {
                print("❌ Samsung TV WebSocket bağlantı hatası port \(port): \(error)")
                lastError = error
                continue
            }
        }
        
        throw lastError ?? TVServiceError.connectionFailed("Samsung TV WebSocket'e hiçbir portta bağlanılamadı")
    }
    
    private func wakeUpSamsungTV() async throws {
        print("🔔 Samsung TV uyandırma süreci başladı...")
        
        let ports = [8002, 8001, 8080, 55000]
        
        await withTaskGroup(of: Void.self) { group in
            for port in ports {
                group.addTask {
                    print("🔔 Samsung TV Port \(port) için uyandırma isteği gönderiliyor...")
                    
                    let wakeUpURL = URL(string: "http://\(self.device.ipAddress):\(port)/")!
                    print("🔔 Samsung TV Uyandırma URL: \(wakeUpURL)")
                    
                    var wakeUpRequest = URLRequest(url: wakeUpURL)
                    wakeUpRequest.timeoutInterval = 2.0
                    wakeUpRequest.httpMethod = "GET"
                    
                    do {
                        let (_, response) = try await self.urlSession?.data(for: wakeUpRequest) ?? (Data(), URLResponse())
                        if let httpResponse = response as? HTTPURLResponse {
                            print("✅ Samsung TV Uyandırma isteği başarılı - port \(port), status: \(httpResponse.statusCode)")
                        }
                    } catch {
                        print("❌ Samsung TV Uyandırma isteği hatası - port \(port): \(error)")
                    }
                    
                    let permissionURL = URL(string: "http://\(self.device.ipAddress):\(port)/api/v2/applications")!
                    print("🔔 Samsung TV İzin popup tetikleme URL: \(permissionURL)")
                    
                    var permissionRequest = URLRequest(url: permissionURL)
                    permissionRequest.httpMethod = "POST"
                    permissionRequest.timeoutInterval = 2.0
                    permissionRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    permissionRequest.setValue("ArcTVRemote", forHTTPHeaderField: "User-Agent")
                    
                    let permissionData = [
                        "name": "ArcTVRemote",
                        "token": ""
                    ] as [String : Any]
                    
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: permissionData)
                        permissionRequest.httpBody = jsonData
                        
                        let (_, permissionResponse) = try await self.urlSession?.data(for: permissionRequest) ?? (Data(), URLResponse())
                        if let httpResponse = permissionResponse as? HTTPURLResponse {
                            print("✅ Samsung TV İzin popup tetikleme başarılı - port \(port), status: \(httpResponse.statusCode)")
                        }
                    } catch {
                        print("❌ Samsung TV İzin popup tetikleme hatası - port \(port): \(error)")
                    }
                }
            }
        }
        
        try await Task.sleep(nanoseconds: 500_000_000)
        
        print("🔔 Samsung TV uyandırma süreci tamamlandı")
    }
    
    private func connectWithToken(_ token: String) async throws {
        let webSocketURL = createWebSocketURL(token: token, port: device.port)
        print("🌐 Samsung TV Token ile bağlantı URL: \(webSocketURL)")
        
        let oldWebSocketTask = webSocketTask
        webSocketTask = nil
        
        oldWebSocketTask?.cancel(with: .goingAway, reason: nil)
        
        try await Task.sleep(nanoseconds: 100_000_000)
        
        var urlRequest = URLRequest(url: webSocketURL)
        urlRequest.networkServiceType = .responsiveData
        urlRequest.timeoutInterval = 60
        
        webSocketTask = urlSession?.webSocketTask(with: urlRequest)
        webSocketTask?.resume()
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            var hasResumed = false
            let connectionId = UUID()
            self.connectionContinuation = continuation
            self.currentConnectionId = connectionId
            
            let timeout = DispatchTime.now() + .seconds(60)
            DispatchQueue.global().asyncAfter(deadline: timeout) {
                guard !hasResumed, self.currentConnectionId == connectionId else { return }
                hasResumed = true
                self.connectionContinuation = nil
                self.currentConnectionId = nil
                continuation.resume(throwing: TVServiceError.connectionFailed("WebSocket bağlantı timeout"))
            }
            
            webSocketTask?.receive { result in
                guard !hasResumed, self.currentConnectionId == connectionId else { return }
                
                switch result {
                case .success(let message):
                    print("✅ Samsung TV WebSocket bağlantısı açıldı (token ile)")
                    self.handleWebSocketMessage(message)
                    self.startReceivingMessages()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        guard !hasResumed, self.currentConnectionId == connectionId else { return }
                        
                        if self.isAuthorizationRejected {
                            hasResumed = true
                            self.connectionContinuation = nil
                            self.currentConnectionId = nil
                            continuation.resume(throwing: TVServiceError.connectionFailed("Samsung TV izni reddedildi"))
                        } else if self.isConnected && self.webSocketTask?.state == .running {
                            hasResumed = true
                            self.connectionContinuation = nil
                            self.currentConnectionId = nil
                            continuation.resume()
                        } else {
                            hasResumed = true
                            self.connectionContinuation = nil
                            self.currentConnectionId = nil
                            self.isConnected = false
                            continuation.resume(throwing: TVServiceError.connectionFailed("Samsung TV bağlantı doğrulanamadı"))
                        }
                    }
                case .failure(let error):
                    guard !hasResumed, self.currentConnectionId == connectionId else { return }
                    hasResumed = true
                    self.connectionContinuation = nil
                    self.currentConnectionId = nil
                    print("❌ Samsung TV WebSocket bağlantı hatası \(webSocketURL): \(error)")
                    self.isConnected = false
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
        guard isConnected, let webSocketTask = webSocketTask, webSocketTask.state == .running else {
            isConnected = false
            throw TVServiceError.connectionFailed("Samsung TV bağlantısı yok")
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
        case "volumeup", "volume_up", "increase":
            return "KEY_VOLUP"
        case "volumedown", "volume_down", "decrease":
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
        case "options", "settings", "menu":
            return "KEY_MENU"
        case "colorsshortcut":
            return "KEY_COLOR"
        case "smarthub":
            return "KEY_HOME"
        case "caption":
            return "KEY_CAPTION"
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
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                if let event = json["event"] as? String {
                    switch event {
                    case "ms.channel.connect":
                        if let dataDict = json["data"] as? [String: Any],
                           let token = dataDict["token"] as? String {
                            print("🔑 Samsung TV token alındı: \(token)")
                            setDeviceToken(token, deviceId: device.id.uuidString)
                            
                            if let continuation = connectionContinuation, currentConnectionId != nil {
                                let cont = continuation
                                let connectionId = currentConnectionId
                                connectionContinuation = nil
                                currentConnectionId = nil
                                
                                print("✅ Samsung TV izin verildi! İlk bağlantı tamamlanıyor, token ile yeniden bağlanıyor...")
                                
                                DispatchQueue.main.async {
                                    cont.resume()
                                }
                                
                                Task {
                                    do {
                                        try await connectWithToken(token)
                                        print("✅ Samsung TV token ile bağlantı başarılı!")
                                    } catch {
                                        print("❌ Samsung TV token ile bağlantı hatası: \(error)")
                                        isConnected = false
                                        DispatchQueue.main.async {
                                            self.delegate?.tvService(self, didReceiveError: error)
                                        }
                                    }
                                }
                            } else {
                                print("✅ Samsung TV izin verildi! Token ile yeniden bağlanıyor...")
                                
                                Task {
                                    do {
                                        try await connectWithToken(token)
                                        print("✅ Samsung TV token ile bağlantı başarılı!")
                                    } catch {
                                        print("❌ Samsung TV token ile bağlantı hatası: \(error)")
                                        isConnected = false
                                        DispatchQueue.main.async {
                                            self.delegate?.tvService(self, didReceiveError: error)
                                        }
                                    }
                                }
                            }
                        } else {
                            print("✅ Samsung TV channel connect eventi alındı (token ile bağlantı)")
                            if !isConnected {
                                isConnected = true
                                DispatchQueue.main.async {
                                    self.delegate?.tvService(self, didConnect: self.device)
                                }
                            }
                        }
                    case "ms.channel.unauthorized":
                        print("❌ Samsung TV izni reddedildi")
                        isConnected = false
                        isAuthorizationRejected = true
                        setDeviceToken("", deviceId: device.id.uuidString)
                        
                        if let continuation = connectionContinuation, currentConnectionId != nil {
                            let cont = continuation
                            let connectionId = currentConnectionId
                            connectionContinuation = nil
                            currentConnectionId = nil
                            DispatchQueue.main.async {
                                cont.resume(throwing: TVServiceError.connectionFailed("Samsung TV izni reddedildi"))
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.delegate?.tvService(self, didReceiveError: TVServiceError.connectionFailed("Samsung TV izni reddedildi"))
                            }
                        }
                    case "ms.channel.timeOut":
                        print("⏰ Samsung TV channel timeout - bağlantı korunuyor")
                    default:
                        if !isConnected {
                            print("✅ Samsung TV bağlantı başarılı (event: \(event))")
                            isConnected = true
                            DispatchQueue.main.async {
                                self.delegate?.tvService(self, didConnect: self.device)
                            }
                        }
                        break
                    }
                } else if let dataDict = json["data"] as? [String: Any],
                          let token = dataDict["token"] as? String {
                    print("🔑 Samsung TV token alındı (data içinde): \(token)")
                    setDeviceToken(token, deviceId: device.id.uuidString)
                    
                    print("✅ Samsung TV izin verildi! Token ile yeniden bağlanıyor...")
                    
                    Task {
                        do {
                            try await connectWithToken(token)
                            print("✅ Samsung TV token ile bağlantı başarılı!")
                        } catch {
                            print("❌ Samsung TV token ile bağlantı hatası: \(error)")
                            isConnected = false
                            DispatchQueue.main.async {
                                self.delegate?.tvService(self, didReceiveError: error)
                            }
                        }
                    }
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
        if let token = token, !token.isEmpty {
            print("✅ Samsung TV token mevcut, bağlantı kontrol ediliyor")
        } else {
            print("📱 Samsung TV token yok, izin popup'ı çıkmalı")
            DispatchQueue.main.async {
                print("📱 Samsung TV'de izin popup'ı çıkmalı! Lütfen TV'de 'İzin Ver' butonuna basın.")
            }
        }
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("❌ Samsung TV WebSocket bağlantısı kapandı - closeCode: \(closeCode)")
        isConnected = false
        pingTimer?.invalidate()
        pingTimer = nil
        DispatchQueue.main.async {
            self.delegate?.tvService(self, didDisconnect: self.device)
        }
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        print("🔐 Samsung TV SSL Challenge alındı: \(challenge.protectionSpace.authenticationMethod)")
        print("🔐 Samsung TV Host: \(challenge.protectionSpace.host)")
        
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            print("🔐 Samsung TV SSL sertifikası tamamen devre dışı bırakılıyor...")
            let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(.useCredential, credential)
        } else if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodClientCertificate {
            print("🔐 Samsung TV Client Certificate challenge - devre dışı bırakılıyor")
            completionHandler(.useCredential, nil)
        } else {
            print("🔐 Samsung TV SSL challenge başka bir yöntem: \(challenge.protectionSpace.authenticationMethod)")
            completionHandler(.performDefaultHandling, nil)
        }
    }
}

extension SamsungTVService {
    private func setPingTimer() {
        DispatchQueue.main.async {
            self.pingTimer?.invalidate()
            self.pingTimer = Timer.scheduledTimer(timeInterval: 30.0,
                                                  target: self,
                                                  selector: #selector(self.ping),
                                                  userInfo: nil,
                                                  repeats: true)
            self.pingTimer?.fire()
        }
    }
    
    @objc private func ping() {
        guard isConnected else { return }
        
        webSocketTask?.sendPing { [weak self] error in
            if let error = error {
                print("❌ Samsung TV ping hatası: \(error)")
                self?.handlePingError()
            }
        }
    }
    
    private func handlePingError() {
        guard isConnected else { return }
        
        print("🔄 Samsung TV ping hatası nedeniyle bağlantı kontrol ediliyor...")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            guard self.isConnected else { return }
            
            Task {
                do {
                    try await self.connect()
                } catch {
                    print("❌ Samsung TV yeniden bağlantı hatası: \(error)")
                }
            }
        }
    }
    
    private func startReceivingMessages() {
        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let message):
                if self.isConnected {
                    self.handleWebSocketMessage(message)
                    self.startReceivingMessages()
                }
            case .failure(let error):
                print("❌ Samsung TV WebSocket mesaj alma hatası: \(error)")
                if self.isConnected {
                    self.isConnected = false
                    DispatchQueue.main.async {
                        self.delegate?.tvService(self, didDisconnect: self.device)
                    }
                    self.handlePingError()
                }
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
        "PowerOff": "KEY_POWEROFF",
        "Keyboard": "KEY_ENTER",
        "Backspace": "KEY_BACKSPACE"
    ]
}
