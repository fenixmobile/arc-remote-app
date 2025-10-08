import Foundation
import FXFramework

class InAppPurchaseHelper {
    static let shared = InAppPurchaseHelper()
    
    let fxPurchase: FXPurchase
    
    private init() {
        let config = AdaptyFXPurchaseConfig(apiKey: Constants.Adapty.apiKey, localeCode: Constants.Adapty.localeCode)
        fxPurchase = AdaptyFXPurchase(config: config)
    }
    
    func getPremiumInfo(completion: @escaping (Bool) -> Void) {
        fxPurchase.getPurchaseInfo { result in
            switch result {
            case .success(let purchaseInfo):
                let isPremium = purchaseInfo.info["premium"] as? Bool ?? false
                completion(isPremium)
            case .failure(let error):
                print("❌ Premium check failed: \(error)")
                completion(false)
            }
        }
    }
}