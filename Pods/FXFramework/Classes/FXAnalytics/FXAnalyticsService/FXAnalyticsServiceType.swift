//
//  FXAnalyticsType.swift
//  FXAnalytics
//
//  Created by Savaş Salihoğlu on 13.10.2023.
//

import Foundation

public enum FXAnalyticsServiceType {
    case adjust
    case amplitude
    case facebook
    case firebase
    
    var attributionSource: String {
        switch self {
        case .adjust:
            return "adjust"
        case .amplitude:
            return "amplitude"
        case .facebook:
            return "facebook"
        case .firebase:
            return "firebase"
        }
    }
}
