import Foundation

struct AppSession {
    let buttonText: String
    let userId: Int
    let adjust: Bool
    let requestFrequency: Int
    let requestForReview: Bool
    let showBannerAds: Bool
    let showInterstitialAds: Bool
    let interstitialAdsFrequency: Int
    let uuid: String
    let languageCode: String
    let isPremium: Bool
    let isTrial: Bool
    let token: String
    let logLevel: String
    let chatCount: Int
    let freeChatLimit: Int
    
    func getAllProductIds() -> [String] {
        return []
    }
}
