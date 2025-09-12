//
//  AdjustFXAnalyticsServiceTokenDelegate.swift
//  FXAnalytics
//
//  Created by Savaş Salihoğlu on 30.10.2023.
//

import Foundation

public protocol AdjustFXAnalyticsServiceTokenDelegate {
    func getToken(by event: String) -> String?
}
