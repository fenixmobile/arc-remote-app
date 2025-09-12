//
//  AdjustFXEnvironment.swift
//  FXAnalytics
//
//  Created by Savaş Salihoğlu on 23.10.2023.
//

import Foundation
import AdjustSdk

public enum AdjustFXEnvironment {
    case adjustFXEnvironmentSandbox
    case adjustFXEnvironmentProduction
    
    var ajdEnvironment: String {
        switch self {
        case .adjustFXEnvironmentSandbox:
            return ADJEnvironmentSandbox
        default:
            return ADJEnvironmentProduction
        }
    }
}
