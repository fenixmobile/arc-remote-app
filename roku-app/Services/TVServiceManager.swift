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
    var currentService: TVServiceProtocol?

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
    
    func startIncrementalDiscovery() {
        DispatchQueue.main.async {
            self.isDiscovering = true
        }
        
        discoveryManager.startIncrementalDiscovery()
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
            } else if let androidService = service as? AndroidTVService {
                device.port = androidService.device.port
                print("🔗 Android TV port güncellendi: \(device.port)")
            }
            
            currentService = service
            connectedDeviceIds.insert(device.id)
            print("🔗 Current service saklandı: \(device.id)")
            
            AnalyticsManager.shared.fxAnalytics.send(event: "device_connect_success", properties: [
                "device_type": device.brand.displayName,
                "device_name": device.name
            ])
        } catch {
            print("❌ Bağlantı başarısız: \(error)")
            
            AnalyticsManager.shared.fxAnalytics.send(event: "device_connect_fail", properties: [
                "device_type": device.brand.displayName,
                "device_name": device.name
            ])
            
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
        
        do {
            try await service.connect()
            
            AnalyticsManager.shared.fxAnalytics.send(event: "device_connect_pin_ok_success", properties: [
                "device_type": device.brand.displayName,
                "device_name": device.name
            ])
            
            let finalDevice = device
            DispatchQueue.main.async {
                self.currentDevice = finalDevice
                if !self.connectedDevices.contains(where: { $0.id == finalDevice.id }) {
                    self.connectedDevices.append(finalDevice)
                }
            }
        } catch {
            AnalyticsManager.shared.fxAnalytics.send(event: "device_connect_pin_ok_failure", properties: [
                "device_type": device.brand.displayName,
                "device_name": device.name
            ])
            
            throw error
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
    
    func discoverAndroidTVDevices() async throws -> [TVDevice] {
        var discoveredDevices: [TVDevice] = []
        
        let localNetwork = await getLocalNetworkRange()
        
        await withTaskGroup(of: [TVDevice].self) { group in
            for ip in localNetwork {
                group.addTask {
                    return await self.scanIPForAndroidTV(ip)
                }
            }
            
            for await devices in group {
                discoveredDevices.append(contentsOf: devices)
            }
        }
        
        return discoveredDevices
    }
    
    private func getLocalNetworkRange() async -> [String] {
        var ips: [String] = []
        
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "NetworkMonitor")
        
        return await withCheckedContinuation { continuation in
            monitor.pathUpdateHandler = { path in
                if path.status == .satisfied {
                    for interface in path.availableInterfaces {
                        if case .wifi = interface.type {
                            let connection = NWConnection(host: NWEndpoint.Host("8.8.8.8"), port: NWEndpoint.Port(integerLiteral: 53), using: .udp)
                            connection.stateUpdateHandler = { state in
                                if case .ready = state {
                                    if let localEndpoint = connection.currentPath?.localEndpoint,
                                       case .hostPort(let host, _) = localEndpoint {
                                        let ipString = String(describing: host)
                                        let baseIP = ipString.components(separatedBy: ".").prefix(3).joined(separator: ".")
                                        for i in 1...254 {
                                            ips.append("\(baseIP).\(i)")
                                        }
                                    }
                                    connection.cancel()
                                }
                            }
                            connection.start(queue: queue)
                            break
                        }
                    }
                }
                monitor.cancel()
                continuation.resume(returning: ips)
            }
            monitor.start(queue: queue)
        }
    }
    
    private func scanIPForAndroidTV(_ ip: String) async -> [TVDevice] {
        let ports = [6467, 6466]
        
        for port in ports {
            if await isAndroidTVDevice(ip: ip, port: port) {
                let device = TVDevice(
                    name: "Android TV Device",
                    brand: .androidTV,
                    ipAddress: ip,
                    port: port
                )
                return [device]
            }
        }
        
        return []
    }
    
    private func isAndroidTVDevice(ip: String, port: Int) async -> Bool {
        let host = NWEndpoint.Host(ip)
        let port = NWEndpoint.Port(integerLiteral: UInt16(port))
        
        return await withCheckedContinuation { continuation in
            let connection = NWConnection(host: host, port: port, using: .tcp)
            
            connection.stateUpdateHandler = { state in
                switch state {
                case .ready:
                    connection.cancel()
                    continuation.resume(returning: true)
                case .failed, .cancelled:
                    continuation.resume(returning: false)
                default:
                    break
                }
            }
            
            connection.start(queue: .global())
            
            DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
                connection.cancel()
                continuation.resume(returning: false)
            }
        }
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
    
    func didDiscoverDevicesIncremental(_ devices: [TVDevice]) {
        DispatchQueue.main.async {
            self.updateDiscoveredDevicesIncremental(devices)
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
    
    func tvService(_ service: TVServiceProtocol, didDiscoverDevicesIncremental devices: [TVDevice]) {
        print("🔗 TVServiceManager: tvService didDiscoverDevicesIncremental çağrıldı - \(devices.count) cihaz")
        
        DispatchQueue.main.async {
            self.updateDiscoveredDevicesIncremental(devices)
        }
    }
    
    private func updateDiscoveredDevicesIncremental(_ newDevices: [TVDevice]) {
        var updatedDevices = discoveredDevices
        
        for newDevice in newDevices {
            if let existingIndex = updatedDevices.firstIndex(where: { $0.ipAddress == newDevice.ipAddress }) {
                updatedDevices[existingIndex] = newDevice
            } else {
                updatedDevices.append(newDevice)
            }
        }
        
        let currentDeviceIPs = Set(newDevices.map { $0.ipAddress })
        updatedDevices = updatedDevices.filter { currentDeviceIPs.contains($0.ipAddress) }
        
        discoveredDevices = updatedDevices
        updateDiscoveryMessage()
    }
    
    func tvService(_ service: TVServiceProtocol, didRequestPin device: TVDevice) {
        print("🔗 TVServiceManager: tvService didRequestPin çağrıldı - \(device.name)")
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: NSNotification.Name("TVServiceDidRequestPin"),
                object: nil,
                userInfo: ["device": device]
            )
        }
    }
    
    func getCurrentDevices() -> [TVDevice] {
        return discoveredDevices
    }
}
