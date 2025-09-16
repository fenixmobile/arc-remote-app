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
    private var connectedServices: [UUID: TVServiceProtocol] = [:]

    init() {
        setupServices()
        startMonitoringNetwork()
    }

    private func setupServices() {
        // Servisler artık dinamik olarak oluşturulacak
        // Dummy data kullanmıyoruz
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
        networkMonitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                print("Network is available.")
            } else {
                print("No network connection.")
            }
        }
        networkMonitor.start(queue: queue)
    }

    func connectToDevice(_ device: inout TVDevice) async throws {
        print("🔗 Cihaza bağlanılıyor: \(device.name) - \(device.ipAddress):\(device.port)")
        
        let service: TVServiceProtocol
        
        switch device.brand {
        case .roku:
            service = RokuTVService(device: device)
        case .samsung:
            service = SamsungTVService(device: device)
        case .fireTV:
            service = FireTVService(device: device)
        case .sony:
            service = SonyTVService(device: device)
        case .tcl:
            service = TCLTVService(device: device)
        case .lg:
            service = LGTVService(device: device)
        case .philipsAndroid:
            service = PhilipsAndroidTVService(device: device)
        case .philips:
            service = PhilipsTVService(device: device)
        case .vizio:
            service = VizioTVService(device: device)
        case .androidTV:
            service = AndroidTVService(device: device)
        case .toshiba:
            service = ToshibaTVService(device: device)
        case .panasonic:
            service = PanasonicTVService(device: device)
        }

        print("🔗 Servis oluşturuldu, bağlantı kuruluyor...")
        do {
            try await service.connect()
            print("✅ Bağlantı başarılı!")
            // Service'de güncellenen port'u device'a yansıt
            if let rokuService = service as? RokuTVService {
                device.port = rokuService.device.port
                print("🔗 Roku port güncellendi: \(device.port)")
            } else if let samsungService = service as? SamsungTVService {
                device.port = samsungService.device.port
                print("🔗 Samsung port güncellendi: \(device.port)")
            }
            
            // Connected service'i sakla
            connectedServices[device.id] = service
            connectedDeviceIds.insert(device.id)
            print("🔗 Connected service saklandı: \(device.id)")
        } catch {
            print("❌ Bağlantı başarısız: \(error)")
            throw error
        }

        let finalDevice = device
        DispatchQueue.main.async {
            print("🔗 currentDevice güncelleniyor: \(finalDevice.name) - \(finalDevice.brand)")
            self.currentDevice = finalDevice
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
        
        let service: TVServiceProtocol
        
        switch device.brand {
        case .roku:
            service = RokuTVService(device: device)
        case .samsung:
            service = SamsungTVService(device: device)
        case .fireTV:
            service = FireTVService(device: device)
        case .sony:
            service = SonyTVService(device: device)
        case .tcl:
            service = TCLTVService(device: device)
        case .lg:
            service = LGTVService(device: device)
        case .philipsAndroid:
            service = PhilipsAndroidTVService(device: device)
        case .philips:
            service = PhilipsTVService(device: device)
        case .vizio:
            service = VizioTVService(device: device)
        case .androidTV:
            service = AndroidTVService(device: device)
        case .toshiba:
            service = ToshibaTVService(device: device)
        case .panasonic:
            service = PanasonicTVService(device: device)
        }

        service.disconnect()

        DispatchQueue.main.async {
            self.currentDevice = nil
            self.connectedDevices.removeAll(where: { $0.id == device.id })
            self.connectedDeviceIds.remove(device.id)
            self.connectedServices.removeValue(forKey: device.id)
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
        let service: TVServiceProtocol
        
        switch device.brand {
        case .roku:
            service = RokuTVService(device: device)
        case .samsung:
            service = SamsungTVService(device: device)
        case .fireTV:
            service = FireTVService(device: device)
        case .sony:
            service = SonyTVService(device: device)
        case .tcl:
            service = TCLTVService(device: device)
        case .lg:
            service = LGTVService(device: device)
        case .philipsAndroid:
            service = PhilipsAndroidTVService(device: device)
        case .philips:
            service = PhilipsTVService(device: device)
        case .vizio:
            service = VizioTVService(device: device)
        case .androidTV:
            service = AndroidTVService(device: device)
        case .toshiba:
            service = ToshibaTVService(device: device)
        case .panasonic:
            service = PanasonicTVService(device: device)
        }
        
        do {
            try await service.connect()
            print("✅ Discovery sırasında bağlantı başarılı: \(device.name) - \(device.ipAddress):\(device.port)")
            
            // Service'de güncellenen port'u device'a yansıt
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
        
        // Connected service'i kullan, yoksa yeni oluştur
        var service: TVServiceProtocol
        
        if let connectedService = connectedServices[device.id] {
            service = connectedService
            // Connected service'in isConnected property'sini true yap
            if let baseService = service as? BaseTVService {
                baseService.isConnected = true
            }
            print("🎮 Connected service kullanılıyor: \(device.brand)")
        } else {
            print("🎮 Yeni service oluşturuluyor: \(device.brand)")
            switch device.brand {
            case .roku:
                service = RokuTVService(device: device)
            case .samsung:
                service = SamsungTVService(device: device)
            case .fireTV:
                service = FireTVService(device: device)
            case .sony:
                service = SonyTVService(device: device)
            case .tcl:
                service = TCLTVService(device: device)
            case .lg:
                service = LGTVService(device: device)
            case .philipsAndroid:
                service = PhilipsAndroidTVService(device: device)
            case .philips:
                service = PhilipsTVService(device: device)
            case .vizio:
                service = VizioTVService(device: device)
            case .androidTV:
                service = AndroidTVService(device: device)
            case .toshiba:
                service = ToshibaTVService(device: device)
            case .panasonic:
                service = PanasonicTVService(device: device)
            }
        }
        
        try await service.sendCommand(command)
    }
    
    func getStoredConnectedTVService() -> TVServiceProtocol? {
        guard let device = currentDevice else { return nil }
        
        switch device.brand {
        case .roku, .tcl:
            return RokuTVService(device: device)
        case .fireTV:
            return FireTVService(device: device)
        case .samsung:
            return SamsungTVService(device: device)
        case .sony:
            return SonyTVService(device: device)
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

enum TVServiceError: Error {
    case unsupportedBrand
    case connectionFailed(String)
    case commandFailed(String)
    case deviceNotFound
    case networkError
}