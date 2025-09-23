//
//  DeviceDiscoveryManager.swift
//  roku-app
//
//  Created by Ali İhsan Çağlayan on 18.09.2025.
//

import Foundation
import Network
import XMLCoder

protocol DeviceDiscoveryDelegate: AnyObject {
    func didDiscoverDevice(_ device: TVDevice)
    func didFinishDiscovery()
    func didUpdateDiscoveryMessage(_ message: String)
}

class DeviceDiscoveryManager {
    weak var delegate: DeviceDiscoveryDelegate?
    
    private var ssdpClients: [SSDPDiscovery] = []
    private let queue = DispatchQueue(label: "DeviceDiscovery")
    
    func startDiscovery() {
        delegate?.didUpdateDiscoveryMessage("Cihazlar aranıyor...")
        
        startSSDPDiscovery()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            self?.stopDiscovery()
        }
    }
    
    func stopDiscovery() {
        ssdpClients.forEach { $0.stop() }
        ssdpClients.removeAll()
        delegate?.didFinishDiscovery()
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
    
    private func addDevice(sharedTVDTO: SharedTVDTO, host: String, port: Int = 8080) {
        guard let manufacturer = sharedTVDTO.device?.manufacturer?.lowercased() else { return }
        guard let modelName = sharedTVDTO.device?.modelName?.lowercased() else { return }
        
        let brand = determineBrand(from: manufacturer, modelName: modelName)
        let deviceName = createDeviceName(from: sharedTVDTO, brand: brand)
        
        let device = TVDevice(
            name: deviceName,
            brand: brand,
            ipAddress: host,
            port: port
        )
        
        delegate?.didDiscoverDevice(device)
    }
    
    private func determineBrand(from manufacturer: String, modelName: String) -> TVBrand {
        switch manufacturer {
        case _ where manufacturer.contains("samsung"):
            return .samsung
        case _ where manufacturer.contains("roku"):
            return .roku
        case _ where manufacturer.contains("amazon"):
            return .fireTV
        case _ where manufacturer.contains("sony"):
            return .sony
        case _ where manufacturer.contains("lg"):
            return .lg
        case _ where manufacturer.contains("tcl") && !manufacturer.contains("roku") && !manufacturer.contains("amazon"):
            return .tcl
        case _ where manufacturer.contains("vizio"):
            return .vizio
        case _ where manufacturer.contains("android") && !manufacturer.contains("roku") && !manufacturer.contains("amazon") && !manufacturer.contains("tcl") && !manufacturer.contains("philips") && !manufacturer.contains("lg") && !manufacturer.contains("sony") && !manufacturer.contains("samsung"):
            return .androidTV
        case _ where manufacturer.contains("xiaomi"):
            return .androidTV
        case _ where manufacturer.contains("toshiba"):
            return .toshiba
        case _ where manufacturer.contains("panasonic"):
            return .panasonic
        case _ where modelName.contains("philips"):
            return .philipsAndroid
        default:
            return .androidTV
        }
    }
    
    private func createDeviceName(from sharedTVDTO: SharedTVDTO, brand: TVBrand) -> String {
        let deviceName = sharedTVDTO.device?.friendlyDeviceName ?? "Unknown Device"
        
        if deviceName == "Unknown Device" {
            let friendlyName = sharedTVDTO.device?.friendlyName ?? ""
            let modelName = sharedTVDTO.device?.modelName ?? ""
            let modelNumber = sharedTVDTO.device?.modelNumber ?? ""
            let brandName = brand.displayName
            
            if !friendlyName.isEmpty {
                return friendlyName
            } else if !modelName.isEmpty {
                if brand == .samsung && !modelNumber.isEmpty {
                    return "\(brandName) \(modelName) \(modelNumber) TV"
                } else if brand == .roku || brand == .androidTV {
                    return modelName
                } else if brand == .philipsAndroid {
                    return "\(brandName) \(modelName)"
                } else {
                    return "\(brandName) \(modelName)"
                }
            } else {
                return "\(brandName) TV"
            }
        } else {
            return deviceName
        }
    }
}

extension DeviceDiscoveryManager: SSDPDiscoveryDelegate {
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
}
