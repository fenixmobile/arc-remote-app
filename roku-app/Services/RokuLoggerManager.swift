import Foundation

class RokuLoggerManager {
    static let shared = RokuLoggerManager()
    
    private init() {}
    
    func log(error: Error) {
        print("RokuLogger: \(error.localizedDescription)")
    }
    
    func log(message: String) {
        print("RokuLogger: \(message)")
    }
}
