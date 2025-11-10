import Foundation
import CryptoKit

class AndroidTVService: BaseTVService, URLSessionTaskDelegate {
    
    private var streamTask: URLSessionStreamTask?
    private var urlSession: URLSession = .shared
    private var serverCertificateSecKey: SecKey?
    private var clientCertificateSecKey: SecKey?
    private var pairing: Bool = false
    private var readCounter: Int = 0
    private let pairingManager = PairingMessageManager.shared
    
    override init(device: TVDevice) {
        super.init(device: device)
        delegate = TVServiceManager.shared
        urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
    }
    
    override func connect() async throws {
        await logConnectionAttempt()
        
        do {
            try await startPairing()
            isPaired = true
            isConnected = true
            print("🔐 AndroidTVService: Bağlantı başarılı, isPaired = true yapıldı")
            delegate?.tvService(self, didConnect: device)
        } catch {
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
        
        let startTime = Date()
        
        do {
            try await sendAndroidTVCommand(command.command)
            let responseTime = Date().timeIntervalSince(startTime)
            
            await logCommandSent(command: command.command, success: true, responseTime: responseTime)
        } catch {
            let responseTime = Date().timeIntervalSince(startTime)
            await logCommandSent(command: command.command, success: false, responseTime: responseTime, error: error)
            throw error
        }
    }
    
    override func discoverDevices() async throws -> [TVDevice] {
        return try await TVServiceManager.shared.discoverAndroidTVDevices()
    }
    
    override func testConnection() async throws -> Bool {
        guard !device.id.uuidString.isEmpty else { return false }
        
        if isPaired {
            return true
        }
        
        do {
            try await startPairing()
            return true
        } catch {
            return false
        }
    }
    
    override func disconnect() {
        streamTask?.cancel()
        isConnected = false
        delegate?.tvService(self, didDisconnect: device)
    }
    
    private var isPaired: Bool {
        get {
            let key = "isPairedAndroid\(device.id)"
            let paired = UserDefaults.standard.bool(forKey: key)
            print("🔐 AndroidTVService: isPaired kontrolü - Key: \(key), Paired: \(paired)")
            return paired
        }
        set {
            let key = "isPairedAndroid\(device.id)"
            UserDefaults.standard.setValue(newValue, forKey: key)
            print("🔐 AndroidTVService: isPaired güncellendi - Key: \(key), Paired: \(newValue)")
        }
    }
    
    private func startPairing() async throws {
        print("🔐 AndroidTVService: startPairing çağrıldı - Device: \(device.displayName), isPaired: \(isPaired)")
        if isPaired {
            print("🔐 AndroidTVService: Cihaz zaten eşleşmiş, pairing atlanıyor")
            return
        }
        
        print("🔐 AndroidTVService: Yeni cihaz için pairing başlatılıyor")
        streamTask = urlSession.streamTask(withHostName: device.ipAddress, port: 6467)
        if let streamTask = streamTask {
            streamTask.startSecureConnection()
            streamTask.resume()
            sendPairMessages()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.requestPinInput()
            }
        }
    }
    
    private func requestPinInput() {
        delegate?.tvService(self, didRequestPin: device)
    }
    
    func verifyPin(_ pin: String) async throws {
        guard pin.count == 6 else {
            throw TVServiceError.pinVerificationFailed("PIN must be 6 digits")
        }
        
        if let secret = getPairingSecret(code: pin),
           let message = PairingMessageManager.shared.createPairingSecret(secret: secret) {
            pairing = true
            writeMessage(message)
            
            await logConnectionSuccess()
        } else {
            throw TVServiceError.pinVerificationFailed("Failed to create pairing secret")
        }
    }
    
    private func sendPairMessages() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.writeMessage(PairingMessageManager.shared.createPairingRequest(serviceName: "com.universal.remote")!)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.writeMessage(PairingMessageManager.shared.createPairingOption()!)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.writeMessage(PairingMessageManager.shared.createPairingConfiguration()!)
        }
    }
    
    private func writeMessage(_ data: Data) {
        let number: Int8 = Int8(data.count)
        let data1 = withUnsafeBytes(of: number) { Data($0) }
        streamTask?.write(data1, timeout: 5, completionHandler: { error in
            if error != nil {
                return
            }
            self.streamTask?.write(data, timeout: 5, completionHandler: { error in
                if self.pairing {
                    self.readCounter = 0
                    self.readData()
                }
            })
        })
    }
    
    func readData() {
        self.streamTask?.readData(ofMinLength: 1, maxLength: 512, timeout: 10) { [weak self] data, atEOF, error in
            guard let self = self else { return }
            if let error = error {
                print("Read error: \(error)")
            } else if let data = data {
                let message = PairingMessageManager.shared.parse(data: data)
                print("Data received: \(message?.debugDescription ?? "nil")")
                if self.pairing && self.readCounter == 1 {
                    self.pairing = false
                    if message?.status == .ok {
                        self.isPaired = true
                        self.isConnected = true
                        self.delegate?.tvService(self, didConnect: self.device)
                    } else {
                        self.delegate?.tvService(self, didReceiveError: TVServiceError.pinVerificationFailed("PIN verification failed"))
                    }
                }
            }
            self.readCounter += 1
            if self.readCounter < 2 {
                self.readData()
            } else {
                self.pairing = false
            }
        }
    }
    
    private func sendAndroidTVCommand(_ command: String) async throws {
        guard let keyCode = mapToAndroidTVKeyCode(command) else {
            throw TVServiceError.commandFailed("Unsupported command: \(command)")
        }
        
        reConnectAndWriteMessage(keyCode: keyCode)
    }
    
    private func reConnectAndWriteMessage(keyCode: Remote_RemoteKeyCode) {
        streamTask?.cancel()
        streamTask = urlSession.streamTask(withHostName: device.ipAddress, port: 6466)
        if let streamTask = streamTask {
            streamTask.startSecureConnection()
            streamTask.resume()
            
            self.writeMessage(RemoteMessageManager.shared.createRemoteConfigure()!)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.writeMessage(RemoteMessageManager.shared.createRemoteSetActive(active: 622)!)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.writeMessage(RemoteMessageManager.shared.createRemoteKeyInject(keyCode: keyCode)!)
            }
        }
    }
    
    private func mapToAndroidTVKeyCode(_ command: String) -> Remote_RemoteKeyCode? {
        switch command.lowercased() {
        case "home":
            return .keycodeHome
        case "back":
            return .keycodeBack
        case "up":
            return .keycodeDpadUp
        case "down":
            return .keycodeDpadDown
        case "left":
            return .keycodeDpadLeft
        case "right":
            return .keycodeDpadRight
        case "ok", "select":
            return .keycodeEnter
        case "play":
            return .keycodeMediaPlay
        case "pause":
            return .keycodeMediaPause
        case "playpause":
            return .keycodeMediaPlayPause
        case "stop":
            return .keycodeMediaStop
        case "rewind":
            return .keycodeMediaPrevious
        case "fastforward":
            return .keycodeMediaNext
        case "rev":
            return .keycodeMediaPrevious
        case "fwd":
            return .keycodeMediaNext
        case "volumeup":
            return .keycodeVolumeUp
        case "volumedown":
            return .keycodeVolumeDown
        case "volumemute", "mute":
            return .keycodeMute
        case "poweron", "poweroff", "power":
            return .keycodeTvPower
        case "menu", "options", "settings":
            return .keycodeMenu
        case "backspace":
            return .keycodeDel
        case "keyboard":
            return .keycodeSearch
        default:
            return .keycodeHome
        }
    }
    
    private func getPairingSecret(code: String) -> Data? {
        guard let serverCertificateSecKey = serverCertificateSecKey,
              let clientCertificateSecKey = clientCertificateSecKey else {
            return nil
        }
        
        let serverCertificateSecKeyStr: String = "\(serverCertificateSecKey)"
        let clientCertificateSecKeyStr: String = "\(clientCertificateSecKey)"
        
        guard let clientModStr = extractModules(clientCertificateSecKeyStr),
              let clientMod = dataFromHexString(clientModStr),
              let serverModeStr = extractModules(serverCertificateSecKeyStr),
              let serverMod = dataFromHexString(serverModeStr),
              let clientExp = dataFromHexString("010001"),
              let serverExp = dataFromHexString("010001") else {
            return nil
        }
        
        var sha256 = SHA256()
        
        sha256.update(data: clientMod)
        sha256.update(data: clientExp)
        sha256.update(data: serverMod)
        sha256.update(data: serverExp)
        
        if let data = dataFromHexString(String(code.dropFirst(2))) {
            sha256.update(data: data)
        } else {
            return nil
        }
        
        let hash = sha256.finalize()
        let hashString = hash.compactMap { String(format: "%02x", $0) }.joined()
        
        guard let hashArray = hexStringToBytes(hashString) else { return nil }
        return hashArray
    }
    
    private func extractModules(_ inputString: String) -> String? {
        let pattern = "modulus: ([A-F0-9]+)"
        
        if let regex = try? NSRegularExpression(pattern: pattern) {
            let matches = regex.matches(in: inputString, range: NSRange(inputString.startIndex..., in: inputString))
            
            if let match = matches.first, let range = Range(match.range(at: 1), in: inputString) {
                let modulus = inputString[range]
                return String(modulus)
            }
        }
        return nil
    }
    
    private func dataFromHexString(_ hexString: String) -> Data? {
        let cleanHexString = hexString.filter { $0 != " " }
        
        var data = Data(capacity: cleanHexString.count / 2)
        var index = cleanHexString.startIndex
        while index < cleanHexString.endIndex {
            let byteString = cleanHexString[index...cleanHexString.index(index, offsetBy: 1)]
            if let byte = UInt8(byteString, radix: 16) {
                data.append(byte)
                index = cleanHexString.index(index, offsetBy: 2)
            } else {
                return nil
            }
        }
        return data
    }
    
    private func hexStringToBytes(_ hexString: String) -> Data? {
        return hexString
            .dropFirst(hexString.hasPrefix("0x") ? 2 : 0)
            .compactMap { $0.hexDigitValue.map { UInt8($0) } }
            .reduce(into: (data: Data(capacity: hexString.count / 2), byte: nil as UInt8?)) { partialResult, nibble in
                if let p = partialResult.byte {
                    partialResult.data.append(p + nibble)
                    partialResult.byte = nil
                } else {
                    partialResult.byte = nibble << 4
                }
            }.data
    }
}

extension AndroidTVService {
    
    func urlSession(_ session: URLSession, streamTask: URLSessionStreamTask, didBecome inputStream: InputStream, outputStream: OutputStream) {
        print("Stream task did become input and output stream")
    }
    
    func urlSession(_ session: URLSession, writeClosedFor streamTask: URLSessionStreamTask) {
        print("Write closed for stream task")
    }
    
    func urlSession(_ session: URLSession, readClosedFor streamTask: URLSessionStreamTask) {
        print("Read closed for stream task")
    }
    
    func urlSession(_ session: URLSession, betterRouteDiscoveredFor streamTask: URLSessionStreamTask) {
        print("Better route discovered for stream task")
    }
    
    func urlSession(_ session: URLSession, streamTask: URLSessionStreamTask, didCloseWith error: Error?) {
        if let error = error {
            print("Stream task closed with error: \(error)")
        } else {
            print("Stream task closed successfully")
        }
    }
    
    public func urlSession(_: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        print("🔐 SSL Challenge received: \(challenge.protectionSpace.authenticationMethod)")
        
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodClientCertificate
        else {
            if challenge.protectionSpace.serverTrust == nil {
                print("🔐 No server trust, using nil credential")
                completionHandler(.useCredential, nil)
            } else {
                let trust: SecTrust = challenge.protectionSpace.serverTrust!
                if #available(iOS 15.0, *) {
                    if let certificates = SecTrustCopyCertificateChain(trust) as? [SecCertificate],
                       let certificate = certificates.first {
                        
                        self.serverCertificateSecKey = publicKey(for: certificate)
                        print("🔐 Server certificate key extracted")
                    }
                }
                
                let credential = URLCredential(trust: trust)
                print("🔐 Using server trust credential")
                completionHandler(.useCredential, credential)
            }
            return
        }
        
        print("🔐 Client certificate required, looking for: \(Bundle.main.userCertificateForWebsite)")
        guard let (credential, clientSecKey) = Credentials.urlCredential(for: Bundle.main.userCertificateForWebsite) else {
            print("🔐 Failed to load client certificate")
            if challenge.protectionSpace.serverTrust == nil {
                completionHandler(.useCredential, nil)
            } else {
                let trust: SecTrust = challenge.protectionSpace.serverTrust!
                let credential = URLCredential(trust: trust)
                
                completionHandler(.useCredential, credential)
            }
            return
        }
        
        print("🔐 Client certificate loaded successfully")
        self.clientCertificateSecKey = clientSecKey
        challenge.sender?.use(credential!, for: challenge)
        completionHandler(.useCredential, credential!)
    }
    
    func publicKey(for certificate: SecCertificate) -> SecKey? {
        if #available(iOS 12.0, *) {
            return SecCertificateCopyKey(certificate)
        } else if #available(iOS 10.3, *) {
            return SecCertificateCopyPublicKey(certificate)
        } else {
            var possibleTrust: SecTrust?
            SecTrustCreateWithCertificates(certificate, SecPolicyCreateBasicX509(), &possibleTrust)
            guard let trust = possibleTrust else { return nil }
            var result: SecTrustResultType = .unspecified
            SecTrustEvaluate(trust, &result)
            return SecTrustCopyPublicKey(trust)
        }
    }
}

