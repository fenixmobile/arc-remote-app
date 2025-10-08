//
//  TVRemoteViewModel.swift
//  roku-app
//
//  Created by Sengel on 8.09.2025.
//

import Foundation
import Combine

class TVRemoteViewModel: ObservableObject {
    @Published var connectedDevices: [TVDevice] = []
    @Published var discoveredDevices: [TVDevice] = []
    @Published var currentDevice: TVDevice?
    @Published var isConnecting: Bool = false
    @Published var isDiscovering: Bool = false
    @Published var discoveryMessage: String = ""
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    
    private let tvServiceManager = TVServiceManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        // Bind TVServiceManager's published properties to ViewModel
        tvServiceManager.$connectedDevices
            .receive(on: DispatchQueue.main)
            .assign(to: \.connectedDevices, on: self)
            .store(in: &cancellables)
        
        tvServiceManager.$discoveredDevices
            .receive(on: DispatchQueue.main)
            .assign(to: \.discoveredDevices, on: self)
            .store(in: &cancellables)
        
        tvServiceManager.$currentDevice
            .receive(on: DispatchQueue.main)
            .sink { [weak self] device in
                print("🔗 TVRemoteViewModel: currentDevice değişti - \(device?.displayName ?? "nil")")
                print("🔗 TVRemoteViewModel: currentDevice önceki değer: \(self?.currentDevice?.displayName ?? "nil")")
                self?.currentDevice = device
                print("🔗 TVRemoteViewModel: currentDevice yeni değer: \(self?.currentDevice?.displayName ?? "nil")")
            }
            .store(in: &cancellables)
        
        tvServiceManager.$isDiscovering
            .receive(on: DispatchQueue.main)
            .assign(to: \.isDiscovering, on: self)
            .store(in: &cancellables)
        
        tvServiceManager.$discoveryMessage
            .receive(on: DispatchQueue.main)
            .assign(to: \.discoveryMessage, on: self)
            .store(in: &cancellables)
    }
    
    
    func startDiscovery() {
        errorMessage = nil
        tvServiceManager.startDiscovery()
    }
    
    func startIncrementalDiscovery() {
        errorMessage = nil
        tvServiceManager.startIncrementalDiscovery()
    }
    
    func connectToDevice(_ device: TVDevice) {
        print("🔗 TVRemoteViewModel: connectToDevice çağrıldı - \(device.name)")
        print("🔗 TVRemoteViewModel: Device IP: \(device.ipAddress):\(device.port)")
        print("🔗 TVRemoteViewModel: Device Brand: \(device.brand)")
        isConnecting = true
        errorMessage = nil
        
        Task {
            do {
                print("🔗 TVRemoteViewModel: tvServiceManager.connectToDevice çağrılıyor")
                var mutableDevice = device
                try await tvServiceManager.connectToDevice(&mutableDevice)
                print("✅ TVRemoteViewModel: Bağlantı başarılı")
                DispatchQueue.main.async {
                    self.isConnecting = false
                }
            } catch {
                print("❌ TVRemoteViewModel: Bağlantı hatası - \(error)")
                print("❌ TVRemoteViewModel: Error type: \(type(of: error))")
                DispatchQueue.main.async {
                    self.isConnecting = false
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                }
            }
        }
    }
    
    func disconnectFromDevice(_ device: TVDevice) {
        tvServiceManager.disconnectFromDevice(device)
    }
    
    func addCustomDevice(name: String, brand: TVBrand, ipAddress: String, port: Int = 8080) {
        let customDevice = TVDevice(name: name, brand: brand, ipAddress: ipAddress, port: port)
        
        // Add to discovered devices if not already present
        if !discoveredDevices.contains(where: { $0.ipAddress == ipAddress }) {
            DispatchQueue.main.async {
                self.discoveredDevices.append(customDevice)
            }
        }
    }
    
    
    func sendCommand(_ command: String, parameters: [String: Any]? = nil) {
        print("🎮 TVRemoteViewModel: sendCommand çağrıldı - \(command)")
        print("🎮 TVRemoteViewModel: currentDevice = \(currentDevice?.name ?? "nil")")
        
        guard let device = currentDevice else {
            print("❌ TVRemoteViewModel: currentDevice nil!")
            errorMessage = "No device connected"
            showError = true
            return
        }
        
        print("🎮 TVRemoteViewModel: Device bulundu - \(device.name) (\(device.ipAddress):\(device.port))")
        
        let remoteCommand = TVRemoteCommand(command: command, parameters: parameters)
        
        Task {
            do {
                print("🎮 TVRemoteViewModel: Komut gönderiliyor - \(command)")
                try await tvServiceManager.sendCommand(remoteCommand, to: device)
                print("✅ TVRemoteViewModel: Komut başarıyla gönderildi - \(command)")
            } catch {
                print("❌ TVRemoteViewModel: Komut hatası - \(error)")
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to send command: \(error.localizedDescription)"
                    self.showError = true
                }
            }
        }
    }
    
    
    func pressHome() {
        sendCommand("Home")
    }
    
    func pressBack() {
        sendCommand("Back")
    }
    
    func pressUp() {
        sendCommand("Up")
    }
    
    func pressDown() {
        sendCommand("Down")
    }
    
    func pressLeft() {
        sendCommand("Left")
    }
    
    func pressRight() {
        sendCommand("Right")
    }
    
    func pressSelect() {
        sendCommand("Select")
    }
    
    func pressPlay() {
        sendCommand("Play")
    }
    
    func pressPause() {
        sendCommand("Pause")
    }
    
    func pressStop() {
        sendCommand("Stop")
    }
    
    func pressRewind() {
        sendCommand("Rewind")
    }
    
    func pressFastForward() {
        sendCommand("FastForward")
    }
    
    func volumeUp() {
        sendCommand("VolumeUp")
    }
    
    func volumeDown() {
        sendCommand("VolumeDown")
    }
    
    func volumeMute() {
        sendCommand("VolumeMute")
    }
    
    func powerOn() {
        sendCommand("PowerOn")
    }
    
    func powerOff() {
        sendCommand("PowerOff")
    }
    
    
    func clearError() {
        errorMessage = nil
        showError = false
    }
    
    func getCommandsForCurrentDevice() -> [String: String] {
        guard let device = currentDevice else { return [:] }
        
        switch device.brand {
        case .roku, .tcl:
            return RokuTVService.rokuCommands
        case .fireTV:
            return FireTVService.fireTVCommands
        case .samsung:
            return SamsungTVService.samsungCommands
        case .sony:
            return SonyTVService.sonyCommands
        case .lg:
            return ["Home": "HOME", "Back": "BACK", "Up": "UP", "Down": "DOWN", "Left": "LEFT", "Right": "RIGHT", "Select": "SELECT"]
        default:
            return ["Home": "Home", "Back": "Back", "Up": "Up", "Down": "Down", "Left": "Left", "Right": "Right", "Select": "Select"]
        }
    }
}
