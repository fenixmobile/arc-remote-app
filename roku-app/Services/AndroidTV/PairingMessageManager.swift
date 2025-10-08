import Foundation
import SwiftProtobuf

class PairingMessageManager {
    static let shared = PairingMessageManager()
    
    private var manufacturer: String?
    private var model: String?
    
    private init() {
        loadProtobufSchema()
        loadSystemInfo()
    }
    
    private func loadProtobufSchema() {
    }
    
    private func loadSystemInfo() {
        manufacturer = ""
        model = Constants.App.name
    }
    
    private func createMessage(payload: Pairing_PairingMessage) -> Data? {
        do {
            return try payload.serializedData()
        } catch {
            print("Error serializing message: \(error)")
            return nil
        }
    }
    
    func createPairingRequest(serviceName: String) -> Data? {
        var message = Pairing_PairingMessage()
        var request = Pairing_PairingRequest()
        request.serviceName = serviceName
        request.clientName = model ?? "UnknownModel"
        message.pairingRequest = request
        message.status = .ok
        message.protocolVersion = 2
        return createMessage(payload: message)
    }
    
    func createPairingOption() -> Data? {
        var message = Pairing_PairingMessage()
        var option = Pairing_PairingOption()
        var encoding = Pairing_PairingEncoding()
        encoding.type = .hexadecimal
        encoding.symbolLength = 6
        option.inputEncodings = [encoding]
        option.preferredRole = .input
        message.pairingOption = option
        message.status = .ok
        message.protocolVersion = 2
        return createMessage(payload: message)
    }
    
    func createPairingConfiguration() -> Data? {
        var message = Pairing_PairingMessage()
        var config = Pairing_PairingConfiguration()
        var encoding = Pairing_PairingEncoding()
        encoding.type = .hexadecimal
        encoding.symbolLength = 6
        config.encoding = encoding
        config.clientRole = .input
        message.pairingConfiguration = config
        message.status = .ok
        message.protocolVersion = 2
        return createMessage(payload: message)
    }
    
    func createPairingSecret(secret: Data) -> Data? {
        var message = Pairing_PairingMessage()
        var pairingSecret = Pairing_PairingSecret()
        pairingSecret.secret = secret
        message.pairingSecret = pairingSecret
        message.status = .ok
        message.protocolVersion = 2
        return createMessage(payload: message)
    }
    
    func parse(data: Data) -> Pairing_PairingMessage? {
        do {
            return try Pairing_PairingMessage(serializedData: data)
        } catch {
            print("Error parsing message: \(error)")
            return nil
        }
    }
}
