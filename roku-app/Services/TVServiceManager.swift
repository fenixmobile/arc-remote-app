import Foundation
import Network
import Socket
import XMLCoder

class TVServiceManager: ObservableObject {
    static let shared = TVServiceManager()

    @Published var connectedDevices: [TVDevice] = []
    @Published var discoveredDevices: [TVDevice] = []
    @Published var currentDevice: TVDevice?
    @Published var isDiscovering: Bool = false
    @Published var discoveryMessage: String = ""
    @Published var connectedDeviceIds: Set<UUID> = []

    private let networkMonitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    private var ssdpClients: [SSDPDiscovery] = []
    private var scanCompletion: (([TVDevice], Bool) -> Void)?
    private var currentService: TVServiceProtocol?

    init() {
        setupServices()
        startMonitoringNetwork()
    }

    private func setupServices() {
    }

    func startDiscovery() {
        DispatchQueue.main.async {
            self.isDiscovering = true
            self.discoveryMessage = "Cihazlar aranıyor..."
            self.discoveredDevices = []
        }

        scanCompletion = { [weak self] devices, isFinished in
            DispatchQueue.main.async {
                if !devices.isEmpty {
                    for device in devices {
                        if let self = self, !self.discoveredDevices.contains(where: { $0.ipAddress == device.ipAddress }) {
                            self.discoveredDevices.append(device)
                        }
                    }
                    self?.updateDiscoveryMessage()
                }
                
                if isFinished {
                    self?.isDiscovering = false
                    self?.updateDiscoveryMessage()
                }
            }
        }

        startSSDPDiscovery()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            self?.stopDiscovery()
        }
    }

    func stopDiscovery() {
        ssdpClients.forEach { $0.stop() }
        ssdpClients.removeAll()
        
        DispatchQueue.main.async {
            self.isDiscovering = false
            self.updateDiscoveryMessage()
        }
    }

    private func startSSDPDiscovery() {
        let searchTargets = [
            "urn:dial-multiscreen-org:service:dial:1",
            "urn:lge-com:service:webos-second-screen:1", 
            "roku:ecp",
            "ssdp:all"
        ]

        for (index, target) in searchTargets.enumerated() {
            let client = SSDPDiscovery()
            client.delegate = self
            ssdpClients.append(client)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.2) { [weak self] in
                client.discoverService(forDuration: 3, searchTarget: target)
            }
        }
    }

    private func updateDiscoveryMessage() {
        if discoveredDevices.isEmpty {
            discoveryMessage = "Hiçbir cihaz bulunamadı. Ağınızda TV cihazları var mı?"
        } else {
            discoveryMessage = "\(discoveredDevices.count) cihaz bulundu"
        }
    }

    private func startMonitoringNetwork() {
        #if targetEnvironment(simulator)
        print("⚠️ Network monitoring disabled in simulator to avoid SO_NOWAKEFROMSLEEP warnings")
        return
        #endif
        
        networkMonitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                print("Network is available.")
            } else {
                print("No network connection.")
            }
        }
        networkMonitor.start(queue: queue)
    }

    func getService(for device: TVDevice) -> TVServiceProtocol {
        switch device.brand {
        case .roku:
            return RokuTVService(device: device)
        case .samsung:
            return SamsungTVService(device: device)
        case .fireTV:
            return FireTVService(device: device)
        case .sony:
            return SonyTVService(device: device)
        case .tcl:
            return TCLTVService(device: device)
        case .lg:
            return LGTVService(device: device)
        case .philipsAndroid:
            return PhilipsAndroidTVService(device: device)
        case .philips:
            return PhilipsTVService(device: device)
        case .vizio:
            return VizioTVService(device: device)
        case .androidTV:
            return AndroidTVService(device: device)
        case .toshiba:
            return ToshibaTVService(device: device)
        case .panasonic:
            return PanasonicTVService(device: device)
        }
    }
    
    func connectToDevice(_ device: inout TVDevice) async throws {
        print("🔗 Cihaza bağlanılıyor: \(device.name) - \(device.ipAddress):\(device.port)")
        
        let service = getService(for: device)

        print("🔗 Servis oluşturuldu, bağlantı kuruluyor...")
        do {
            try await service.connect()
            print("✅ Bağlantı başarılı!")
            if let rokuService = service as? RokuTVService {
                device.port = rokuService.device.port
                print("🔗 Roku port güncellendi: \(device.port)")
            } else if let samsungService = service as? SamsungTVService {
                device.port = samsungService.device.port
                print("🔗 Samsung port güncellendi: \(device.port)")
            }
            
            currentService = service
            connectedDeviceIds.insert(device.id)
            print("🔗 Current service saklandı: \(device.id)")
        } catch {
            print("❌ Bağlantı başarısız: \(error)")
            throw error
        }

        let finalDevice = device
        DispatchQueue.main.async {
            print("🔗 TVServiceManager: currentDevice güncelleniyor: \(finalDevice.displayName) - \(finalDevice.brand)")
            print("🔗 TVServiceManager: currentDevice önceki değer: \(self.currentDevice?.displayName ?? "nil")")
            self.currentDevice = finalDevice
            print("🔗 TVServiceManager: currentDevice yeni değer: \(self.currentDevice?.displayName ?? "nil")")
            if !self.connectedDevices.contains(where: { $0.id == finalDevice.id }) {
                self.connectedDevices.append(finalDevice)
            }
        }
    }
    
    func connectToSamsungTVWithPin(_ device: inout TVDevice, pin: String) async throws {
        print("🔗 Samsung TV'ye PIN ile bağlanılıyor: \(device.name) - \(device.ipAddress):\(device.port)")
        
        let service = SamsungTVService(device: device)
        try await service.connect()

        let finalDevice = device
        DispatchQueue.main.async {
            self.currentDevice = finalDevice
            if !self.connectedDevices.contains(where: { $0.id == finalDevice.id }) {
                self.connectedDevices.append(finalDevice)
            }
        }
    }

    func disconnectFromDevice(_ device: TVDevice) {
        print("🔌 Cihazdan bağlantı kesiliyor: \(device.name) - \(device.ipAddress):\(device.port)")
        
        let service = getService(for: device)

        service.disconnect()

        DispatchQueue.main.async {
            self.currentDevice = nil
            self.connectedDevices.removeAll(where: { $0.id == device.id })
            self.connectedDeviceIds.remove(device.id)
            self.currentService = nil
        }
    }

    func isDeviceConnected(_ device: TVDevice) -> Bool {
        return connectedDevices.contains(where: { $0.id == device.id })
    }
}

extension TVServiceManager: SSDPDiscoveryDelegate {
    func ssdpDiscovery(_ discovery: SSDPDiscovery, didDiscoverService service: SSDPService) {
        guard let location = service.location,
              let host = service.host else { return }
        
        getDeviceInfo(urlStr: location, host: host)
    }
    
    func ssdpDiscovery(_ discovery: SSDPDiscovery, didFinishWithError error: Error) {
        print("SSDP Discovery error: \(error)")
    }
    
    func ssdpDiscoveryDidStart(_ discovery: SSDPDiscovery) {
        print("SSDP Discovery started")
    }
    
    func ssdpDiscoveryDidFinish(_ discovery: SSDPDiscovery) {
        print("SSDP Discovery finished")
    }
    
    private func getDeviceInfo(urlStr: String, host: String) {
        guard let url = URL(string: urlStr) else { return }
        
        let port = url.port ?? 8080
        
        
        var urlRequest = URLRequest(url: url)
        urlRequest.timeoutInterval = 3
        urlRequest.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: urlRequest) { [weak self] data, response, error in
            if let data = data {
                if let response: SharedTVDTO = self?.decode(data) {
                    self?.addDevice(sharedTVDTO: response, host: host, port: port)
                }
            }
        }.resume()
    }
    
    private func decode<Response: Decodable>(_ data: Data) -> Response? {
        do {
            let decoder = XMLDecoder()
            let response = try decoder.decode(Response.self, from: data)
            return response
        } catch {
            return nil
        }
    }
    
    private func testDeviceConnection(_ device: inout TVDevice) async {
        let service = getService(for: device)
        
        do {
            try await service.connect()
            print("✅ Discovery sırasında bağlantı başarılı: \(device.name) - \(device.ipAddress):\(device.port)")
            
            if let rokuService = service as? RokuTVService {
                device.port = rokuService.device.port
                print("🔗 Discovery sırasında Roku port güncellendi: \(device.port)")
            } else if let samsungService = service as? SamsungTVService {
                device.port = samsungService.device.port
                print("🔗 Discovery sırasında Samsung port güncellendi: \(device.port)")
            }
            
            let finalDevice = device
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if !self.connectedDevices.contains(where: { $0.id == finalDevice.id }) {
                    self.connectedDevices.append(finalDevice)
                }
            }
        } catch {
            print("❌ Discovery sırasında bağlantı başarısız: \(device.name) - \(error)")
        }
    }
    
    private func addDevice(sharedTVDTO: SharedTVDTO, host: String, port: Int = 8080) {
        guard let manufacturer = sharedTVDTO.device?.manufacturer?.lowercased() else { return }
        guard let modelName = sharedTVDTO.device?.modelName?.lowercased() else { return }
        
        let brand: TVBrand
        let deviceName = sharedTVDTO.device?.friendlyDeviceName ?? "Unknown Device"
        
        switch manufacturer {
        case _ where manufacturer.contains("samsung"):
            brand = .samsung
        case _ where manufacturer.contains("roku"):
            brand = .roku
        case _ where manufacturer.contains("amazon"):
            brand = .fireTV
        case _ where manufacturer.contains("sony"):
            brand = .sony
        case _ where manufacturer.contains("lg"):
            brand = .lg
        case _ where manufacturer.contains("tcl") && !manufacturer.contains("roku") && !manufacturer.contains("amazon"):
            brand = .tcl
        case _ where manufacturer.contains("vizio"):
            brand = .vizio
        case _ where manufacturer.contains("android") && !manufacturer.contains("roku") && !manufacturer.contains("amazon") && !manufacturer.contains("tcl") && !manufacturer.contains("philips") && !manufacturer.contains("lg") && !manufacturer.contains("sony") && !manufacturer.contains("samsung"):
            brand = .androidTV
        case _ where manufacturer.contains("xiaomi"):
            brand = .androidTV
        case _ where manufacturer.contains("toshiba"):
            brand = .toshiba
        case _ where manufacturer.contains("panasonic"):
            brand = .panasonic
        case _ where modelName.contains("philips"):
            brand = .philipsAndroid
        default:
            return
        }
        
        let finalDeviceName: String
        if deviceName == "Unknown Device" {
            let friendlyName = sharedTVDTO.device?.friendlyName ?? ""
            let modelName = sharedTVDTO.device?.modelName ?? ""
            let modelNumber = sharedTVDTO.device?.modelNumber ?? ""
            let brandName = brand.displayName
            
            if !friendlyName.isEmpty {
                finalDeviceName = friendlyName
            } else if !modelName.isEmpty {
                if brand == .samsung && !modelNumber.isEmpty {
                    finalDeviceName = "\(brandName) \(modelName) \(modelNumber) TV"
                } else if brand == .roku || brand == .androidTV {
                    finalDeviceName = modelName
                } else if brand == .philipsAndroid {
                    finalDeviceName = "\(brandName) \(modelName)"
                } else {
                    finalDeviceName = "\(brandName) \(modelName)"
                }
            } else {
                finalDeviceName = "\(brandName) TV"
            }
        } else {
            finalDeviceName = deviceName
        }
        
        var device = TVDevice(
            name: finalDeviceName,
            brand: brand,
            ipAddress: host,
            port: port
        )
        
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if !self.discoveredDevices.contains(where: { $0.ipAddress == device.ipAddress }) {
                self.discoveredDevices.append(device)
                self.updateDiscoveryMessage()
            }
        }
    }
}

struct SharedTVDTO: Codable {
    let device: DeviceInfo?
}

struct DeviceInfo: Codable {
    let udn: String?
    let friendlyDeviceName: String?
    let friendlyName: String?
    let manufacturer: String?
    let modelName: String?
    let modelNumber: String?
    let sec: String?
}

struct SSDPService {
    let host: String?
    let location: String?
    let server: String?
    let searchTarget: String?
    
    init(host: String, response: String) {
        self.host = host
        
        let lines = response.components(separatedBy: "\r\n")
        var location: String?
        var server: String?
        var searchTarget: String?
        
        for line in lines {
            if line.lowercased().hasPrefix("location:") {
                location = String(line.dropFirst(9)).trimmingCharacters(in: .whitespaces)
            } else if line.lowercased().hasPrefix("server:") {
                server = String(line.dropFirst(7)).trimmingCharacters(in: .whitespaces)
            } else if line.lowercased().hasPrefix("st:") {
                searchTarget = String(line.dropFirst(3)).trimmingCharacters(in: .whitespaces)
            }
        }
        
        self.location = location
        self.server = server
        self.searchTarget = searchTarget
    }
}

extension TVServiceManager {
    func sendCommand(_ command: TVRemoteCommand, to device: TVDevice) async throws {
        print("🎮 Komut gönderiliyor: \(command.command) - \(device.name) - \(device.ipAddress):\(device.port)")
        
        var service: TVServiceProtocol
        
        if let currentService = currentService {
            service = currentService
            if let baseService = service as? BaseTVService {
                baseService.isConnected = true
            }
            print("🎮 Current service kullanılıyor: \(device.brand)")
        } else {
            print("🎮 Yeni service oluşturuluyor: \(device.brand)")
            service = getService(for: device)
        }
        
        try await service.sendCommand(command)
    }
    
    func getStoredConnectedTVService() -> TVServiceProtocol? {
        guard let device = currentDevice else { return nil }
        return getService(for: device)
    }
    
    func connectToStoredDevice() {
        guard let device = currentDevice else { return }
        Task {
            do {
                try await connectToDevice(&currentDevice!)
            } catch {
                print("Failed to connect to stored device: \(error)")
            }
        }
    }
}

extension TVServiceManager: TVServiceDelegate {
    func tvService(_ service: TVServiceProtocol, didConnect device: TVDevice) {
        print("🔗 TVServiceManager: tvService didConnect çağrıldı - \(device.displayName)")
        
        currentService = service
        print("🔗 TVServiceManager: Current service güncellendi: \(device.displayName)")
        
        DispatchQueue.main.async {
            print("🔗 TVServiceManager: currentDevice güncelleniyor: \(device.displayName) - \(device.brand)")
            print("🔗 TVServiceManager: currentDevice önceki değer: \(self.currentDevice?.displayName ?? "nil")")
            self.currentDevice = device
            print("🔗 TVServiceManager: currentDevice yeni değer: \(self.currentDevice?.displayName ?? "nil")")
            
            if !self.connectedDevices.contains(where: { $0.id == device.id }) {
                self.connectedDevices.append(device)
            }
        }
    }
    
    func tvService(_ service: TVServiceProtocol, didDisconnect device: TVDevice) {
        print("🔗 TVServiceManager: tvService didDisconnect çağrıldı - \(device.displayName)")
        
        DispatchQueue.main.async {
            self.currentDevice = nil
            self.connectedDevices.removeAll { $0.id == device.id }
        }
    }
    
    func tvService(_ service: TVServiceProtocol, didReceiveError error: Error) {
        print("🔗 TVServiceManager: tvService didReceiveError çağrıldı - \(error.localizedDescription)")
    }
    
    func tvService(_ service: TVServiceProtocol, didDiscoverDevices devices: [TVDevice]) {
        print("🔗 TVServiceManager: tvService didDiscoverDevices çağrıldı - \(devices.count) cihaz")
        
        DispatchQueue.main.async {
            self.discoveredDevices = devices
        }
    }
}

enum TVServiceError: Error {
    case unsupportedBrand
    case connectionFailed(String)
    case commandFailed(String)
    case deviceNotFound
    case networkError
}