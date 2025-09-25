import Foundation
import Security

struct Credentials {
    static func urlCredential(for certificateName: String) -> (URLCredential?, SecKey?)? {
        print("🔐 Looking for certificate: \(certificateName).p12")
        
        guard let certificatePath = Bundle.main.path(forResource: certificateName, ofType: "p12") else {
            print("🔐 Certificate file not found: \(certificateName).p12")
            return nil
        }
        
        print("🔐 Certificate path found: \(certificatePath)")
        
        guard let certificateData = NSData(contentsOfFile: certificatePath) else {
            print("🔐 Failed to read certificate data")
            return nil
        }
        
        print("🔐 Certificate data loaded: \(certificateData.length) bytes")
        
        let options = [kSecImportExportPassphrase as String: "1234"]
        var items: CFArray?
        let status = SecPKCS12Import(certificateData, options as CFDictionary, &items)
        
        print("🔐 PKCS12 import status: \(status)")
        
        guard status == errSecSuccess,
              let itemsArray = items as? [[String: Any]],
              let item = itemsArray.first,
              let identity = item[kSecImportItemIdentity as String] as! SecIdentity? else {
            print("🔐 Failed to extract identity from certificate")
            return nil
        }
        
        print("🔐 Identity extracted successfully")
        
        var privateKey: SecKey?
        let privateKeyStatus = SecIdentityCopyPrivateKey(identity, &privateKey)
        
        print("🔐 Private key copy status: \(privateKeyStatus)")
        
        guard privateKeyStatus == errSecSuccess,
              let privateKey = privateKey else {
            print("🔐 Failed to extract private key")
            return nil
        }
        
        print("🔐 Private key extracted successfully")
        
        let credential = URLCredential(identity: identity, certificates: nil, persistence: .forSession)
        return (credential, privateKey)
    }
}

extension Bundle {
    var userCertificateForWebsite: String {
        return "cert"
    }
}
