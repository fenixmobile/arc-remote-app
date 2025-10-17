//
//  Constants.swift
//  roku-app
//
//  Created by Sengel on 18.09.2025.
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
        static let name = "Universal Remote"
        static let description = "Universal Remote Control for Smart TVs"
        #if DEBUG
        static let apiBaseURL = "https://rokutvapp.com/"
        #else
        static let apiBaseURL = "https://rokutvapp.com/"
        #endif
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
    
    // MARK: - Analytics Configuration
    struct Analytics {
        #if DEBUG
        static let adjustAppToken = "rgbzo43nbhts"
        static let amplitudeApiKey = "934056b14c4e683662950f89b00a244f"
        #else
        static let adjustAppToken = "vrgzpy7xou80"
        static let amplitudeApiKey = "df2d40402771da1104f2d645e8830ff9"
        #endif
    }
    
    // MARK: - TV Configuration
    struct TV {
        static let fireTvApiKey = "0987654321"
    }
}
