import Foundation
import Network

enum LocalNetworkPermissionStatus {
    case granted
    case denied
    case notDetermined
    case checking
}

@available(iOS 14.0, *)
class LocalNetworkPermissionManager: NSObject {
    static let shared: LocalNetworkPermissionManager = LocalNetworkPermissionManager()
    
    private var authorization: LocalNetworkAuthorization?
    private var completion: ((LocalNetworkPermissionStatus) -> Void)?
    
    private override init() {
        super.init()
    }
    
    func checkPermission(completion: @escaping (LocalNetworkPermissionStatus) -> Void) {
        print("LocalNetworkPermissionManager: Permission check started")
        
        self.completion = completion
        self.checkLocalNetworkPermission()
    }
    
    private func checkLocalNetworkPermission() {
        print("LocalNetworkPermissionManager: Checking permission")
        self.authorization = LocalNetworkAuthorization()
        self.authorization?.requestAuthorization { [weak self] granted in
            DispatchQueue.main.async {
                if granted {
                    print("LocalNetworkPermissionManager: Local network granted")
                    self?.completion?(.granted)
                } else {
                    print("LocalNetworkPermissionManager: Local network denied")
                    self?.completion?(.denied)
                }
                self?.authorization = nil
                self?.completion = nil
            }
        }
    }
}

@available(iOS 14.0, *)
public class LocalNetworkAuthorization: NSObject {
    private var browser: NWBrowser?
    private var netService: NetService?
    private var completion: ((Bool) -> Void)?
    private var hasCompleted = false
    
    public func requestAuthorization(completion: @escaping (Bool) -> Void) {
        self.completion = completion
        self.hasCompleted = false
        
        let parameters = NWParameters()
        parameters.includePeerToPeer = true
        
        let browser = NWBrowser(for: .bonjour(type: "_lnp._tcp", domain: nil), using: parameters)
        self.browser = browser
        
        browser.stateUpdateHandler = { [weak self] newState in
            guard let self = self, !self.hasCompleted else { return }
            self.handleBrowserState(newState)
        }
        
        self.netService = NetService(domain: "local.", type:"_lnp._tcp.", name: "LocalNetworkPrivacy", port: 1100)
        self.netService?.delegate = self
        
        self.browser?.start(queue: .main)
        self.netService?.publish()
    }
    
    private func handleBrowserState(_ newState: NWBrowser.State) {
        switch newState {
        case .failed(let error):
            print("LocalNetworkAuthorization: Browser failed: \(error)")
            self.hasCompleted = true
            self.completion?(false)
            self.reset()
        case .ready, .cancelled:
            print("LocalNetworkAuthorization: Browser ready/cancelled")
        case let .waiting(error):
            print("LocalNetworkAuthorization: Permission denied: \(error)")
            self.hasCompleted = true
            self.completion?(false)
            self.reset()
        default:
            print("LocalNetworkAuthorization: Browser state: \(newState)")
        }
    }
    
    private func reset() {
        self.browser?.cancel()
        self.browser = nil
        self.netService?.stop()
        self.netService = nil
        self.completion = nil
    }
}

@available(iOS 14.0, *)
extension LocalNetworkAuthorization: NetServiceDelegate {
    public func netServiceDidPublish(_ sender: NetService) {
        guard !hasCompleted else { return }
        hasCompleted = true
        print("LocalNetworkAuthorization: Permission granted")
        completion?(true)
        self.reset()
    }
    
    public func netService(_ sender: NetService, didNotPublish errorDict: [String: NSNumber]) {
        guard !hasCompleted else { return }
        hasCompleted = true
        print("LocalNetworkAuthorization: NetService did not publish: \(errorDict)")
        completion?(false)
        self.reset()
    }
}