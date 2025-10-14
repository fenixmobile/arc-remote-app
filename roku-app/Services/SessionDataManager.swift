import Foundation

class SessionDataManager {
    static let shared: SessionDataManager = {
        let sessionDataManager: SessionDataManager = .init()
        return sessionDataManager
    }()
    
    func setSession(session: AppSession) {
        buttonText = session.buttonText
        requestFrequency = session.requestFrequency
        requestForReview = session.requestForReview
        showBannerAds = session.showBannerAds
        showInterstitialAds = session.showInterstitialAds
        interstitialAdsFrequency = session.interstitialAdsFrequency
        token = session.token
        logLevel = session.logLevel
    }
    
    var buttonText: String = ""
    var requestFrequency: Int = 0
    var requestForReview: Bool = false
    var showBannerAds: Bool = false
    var showInterstitialAds: Bool = false
    var interstitialAdsFrequency: Int = 5
    
    var logLevel: String {
        get {
            UserDefaults.standard.string(forKey: "logLevel") ?? "OFF"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "logLevel")
        }
    }
    
    var token: String {
        get {
            UserDefaults.standard.string(forKey: "appBearerToken") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "appBearerToken")
        }
    }
    
    var isPremium: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "isPremium")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isPremium")
            NotificationCenter.default.post(name: NSNotification.Name("PremiumStatusChanged"), object: nil, userInfo: ["isPremium": newValue])
        }
    }
    
    var onBoardingSeen: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "onBoardingSeen")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "onBoardingSeen")
        }
    }
    
    func clear() {
        token = ""
        isPremium = false
        logLevel = "OFF"
    }
}
