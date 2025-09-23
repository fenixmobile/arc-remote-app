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
    private let discoveryManager = DeviceDiscoveryManager()
    private var currentService: TVServiceProtocol?

    init() {
        setupServices()
        startMonitoringNetwork()
    }

    private func setupServices() {
        discoveryManager.delegate = self
    }

    func startDiscovery() {
        DispatchQueue.main.async {
            self.isDiscovering = true
            self.discoveredDevices = []
        }
        
        discoveryManager.startDiscovery()
    }

    func stopDiscovery() {
        discoveryManager.stopDiscovery()
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

extension TVServiceManager: DeviceDiscoveryDelegate {
    func didDiscoverDevice(_ device: TVDevice) {
        DispatchQueue.main.async {
            if !self.discoveredDevices.contains(where: { $0.ipAddress == device.ipAddress }) {
                self.discoveredDevices.append(device)
                self.updateDiscoveryMessage()
            }
        }
    }
    
    func didFinishDiscovery() {
        DispatchQueue.main.async {
            self.isDiscovering = false
            self.updateDiscoveryMessage()
        }
    }
    
    func didUpdateDiscoveryMessage(_ message: String) {
        DispatchQueue.main.async {
            self.discoveryMessage = message
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