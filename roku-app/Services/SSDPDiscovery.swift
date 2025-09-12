import Foundation
import Socket

protocol SSDPDiscoveryDelegate {
    func ssdpDiscovery(_ discovery: SSDPDiscovery, didDiscoverService service: SSDPService)
    func ssdpDiscovery(_ discovery: SSDPDiscovery, didFinishWithError error: Error)
    func ssdpDiscoveryDidStart(_ discovery: SSDPDiscovery)
    func ssdpDiscoveryDidFinish(_ discovery: SSDPDiscovery)
}

extension SSDPDiscoveryDelegate {
    func ssdpDiscovery(_ discovery: SSDPDiscovery, didDiscoverService service: SSDPService) {}
    func ssdpDiscovery(_ discovery: SSDPDiscovery, didFinishWithError error: Error) {}
    func ssdpDiscoveryDidStart(_ discovery: SSDPDiscovery) {}
    func ssdpDiscoveryDidFinish(_ discovery: SSDPDiscovery) {}
}

class SSDPDiscovery {
    private var socket: Socket?
    public var delegate: SSDPDiscoveryDelegate?
    
    public var isDiscovering: Bool {
        return self.socket != nil
    }
    
    deinit {
        self.stop()
    }
    
    private func readResponses() {
        do {
            var data = Data()
            let (bytesRead, address) = try self.socket!.readDatagram(into: &data)
            
            if bytesRead > 0 {
                let response = String(data: data, encoding: .utf8)
                let (remoteHost, _) = Socket.hostnameAndPort(from: address!)!
                self.delegate?.ssdpDiscovery(self, didDiscoverService: SSDPService(host: remoteHost, response: response!))
            }
        } catch let error {
            self.forceStop()
            self.delegate?.ssdpDiscovery(self, didFinishWithError: error)
        }
    }
    
    private func readResponses(forDuration duration: TimeInterval) {
        let queue = DispatchQueue.global()
        
        queue.async() {
            while self.isDiscovering {
                self.readResponses()
            }
        }
        
        queue.asyncAfter(deadline: .now() + duration) { [unowned self] in
            self.stop()
        }
    }
    
    private func forceStop() {
        if self.isDiscovering {
            self.socket?.close()
        }
        self.socket = nil
    }
    
    open func discoverService(forDuration duration: TimeInterval = 10, searchTarget: String = "ssdp:all", port: Int32 = 1900) {
        self.delegate?.ssdpDiscoveryDidStart(self)
        
        let message = "M-SEARCH * HTTP/1.1\r\n" +
            "MAN: \"ssdp:discover\"\r\n" +
            "HOST: 239.255.255.250:\(port)\r\n" +
            "ST: \(searchTarget)\r\n" +
            "MX: \(Int(duration))\r\n\r\n"
        
        do {
            self.socket = try Socket.create(type: .datagram, proto: .udp)
            try self.socket!.listen(on: 0)
            
            self.readResponses(forDuration: duration)
            
            try self.socket?.write(from: message, to: Socket.createAddress(for: "239.255.255.250", on: port)!)
        } catch let error {
            self.forceStop()
            self.delegate?.ssdpDiscovery(self, didFinishWithError: error)
        }
    }
    
    open func stop() {
        if self.socket != nil {
            self.forceStop()
            self.delegate?.ssdpDiscoveryDidFinish(self)
        }
    }
}
