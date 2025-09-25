import Foundation

struct LoginResponseDataDTO: Decodable {
    let buttonText: String
    let adjust: Bool
    let userId: Int
    let requestForReview: Bool
    let requestFrequency: Int
    let showInterstitial: Bool
    let interstitialFrequency: Int
    let uuid: String
    let locale: String
    let isPremium: Bool
    var isTrial: Bool?
    var chatCount: Int?
    var freeChatLimit: Int?
    let token: String
    let logLevel: String
    
    private enum CodingKeys: String, CodingKey {
        case buttonText = "buttonText"
        case adjust = "adJust"
        case userId = "userId"
        case requestFrequency = "requestFrequency"
        case requestForReview = "requestForReview"
        case showInterstitial = "showInterstitial"
        case interstitialFrequency = "interstitialFrequency"
        case uuid = "uuid"
        case locale = "locale"
        case isPremium = "isPremium"
        case isTrial = "isTrial"
        case chatCount = "chatCount"
        case freeChatLimit = "freeChatLimit"
        case token = "token"
        case logLevel = "logLevel"
    }
}

extension LoginResponseDataDTO {
    func toModel() -> AppSession {
        return .init(buttonText: buttonText,
                     userId: userId,
                     adjust: adjust,
                     requestFrequency: requestFrequency,
                     requestForReview: requestForReview,
                     showBannerAds: false,
                     showInterstitialAds: showInterstitial,
                     interstitialAdsFrequency: interstitialFrequency,
                     uuid: uuid,
                     languageCode: locale,
                     isPremium: true,
                     isTrial: isTrial ?? false,
                     token: token,
                     logLevel: logLevel,
                     chatCount: chatCount ?? 5,
                     freeChatLimit: freeChatLimit ?? 5)
    }
}
