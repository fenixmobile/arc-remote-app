//
//  Constants.swift
//  roku-app
//
//  Created by Ali İhsan Çağlayan on 18.09.2025.
//

import Foundation

struct Constants {
    
    // MARK: - App URLs
    struct URLs {
        static let shareApp = "https://bit.ly/universal-remote-app"
        static let appStoreReview = "https://apps.apple.com/app/tv-remote-universal-control/id1234567890?action=write-review"
        static let support = "https://rokutvapp.com/support"
        static let privacyPolicy = "https://rokutvapp.com/privacyPolicy"
        static let termsOfUse = "https://rokutvapp.com/termOfUse"
    }
    
    // MARK: - App Information
    struct App {
        static let name = "TV Remote App"
        static let description = "Universal Remote Control for Smart TVs"
        static let bundleIdentifier = "fenixmobile.rmt1.test"
    }
    
    // MARK: - Adapty Configuration
    struct Adapty {
        #if DEBUG
        static let apiKey = "public_live_Dg4uOL9i.tPjWzcZM3oQDWM2Deciz"
        static let localeCode = "en"
        #else
        static let apiKey = "public_live_5eRm2KER.laualwVctq01FSEBRGK4"
        static let localeCode = "en"
        #endif
    }
}
