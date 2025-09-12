//
//  FXPaywall.swift
//
//
//  Created by Savaş Salihoğlu on 11.10.2023.
//

import Foundation

public protocol FXPaywall {
    var identifier: String { get }
    var variationId: String? { get }
    var name: String { get }
    var locale: String { get }
    var remoteConfig: [String: Any]? { get }
    var products: [FXProduct]? { get }
    
    func setProducts(_ products: [FXProduct])
}

extension FXPaywall {
    var defaultLocal: String { "en" }
}
