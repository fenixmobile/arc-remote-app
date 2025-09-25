import Foundation
import FXFramework

class InAppPurchaseHelper {
    static let shared = InAppPurchaseHelper()
    
    let fxPurchase: FXPurchase
    
    private init() {
        let config = AdaptyFXPurchaseConfig(apiKey: Constants.Adapty.apiKey, localeCode: Constants.Adapty.localeCode)
        fxPurchase = AdaptyFXPurchase(config: config)
    }
}