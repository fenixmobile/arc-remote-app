//
//  TVBrand.swift
//  roku-app
//
//  Created by Ali İhsan Çağlayan on 8.09.2025.
//

import Foundation
import UIKit

enum TVBrand: String, CaseIterable, Codable {
    case roku = "Roku TV"
    case fireTV = "Fire TV"
    case samsung = "Samsung TV"
    case sony = "Sony TV"
    case tcl = "TCL TV"
    case tclRoku = "TCL Roku TV"
    case tclAndroid = "TCL Android TV"
    case tclNative = "TCL Native TV"
    case lg = "LG TV"
    case philipsAndroid = "Philips Android TV"
    case philips = "Philips TV"
    case vizio = "Vizio TV"
    case androidTV = "Android TV"
    case toshiba = "Toshiba TV"
    case panasonic = "Panasonic TV"
    
    var displayName: String {
        return self.rawValue
    }
    
    var iconName: String {
        return "\(self.rawValue.lowercased().replacingOccurrences(of: " ", with: ""))-cell"
    }
    
    var tintColor: UIColor {
        switch self {
        case .roku:
            return .systemPurple
        case .fireTV:
            return .systemOrange
        case .samsung:
            return .systemBlue
        case .sony:
            return .systemBlue
        case .tcl:
            return .systemGray
        case .tclRoku:
            return .systemPurple
        case .tclAndroid:
            return .systemGreen
        case .tclNative:
            return .systemGray
        case .lg:
            return .systemRed
        case .philipsAndroid:
            return .systemYellow
        case .philips:
            return .systemYellow
        case .vizio:
            return .systemGreen
        case .androidTV:
            return .systemGreen
        case .toshiba:
            return .systemGray
        case .panasonic:
            return .systemBlue
        }
    }
    
    var connectionType: TVConnectionType {
        switch self {
        case .roku:
            return .rokuProtocol
        case .fireTV:
            return .fireTVProtocol
        case .samsung:
            return .smartThings
        case .sony:
            return .braviaAPI
        case .tcl:
            return .tclNative
        case .tclRoku:
            return .rokuProtocol
        case .tclAndroid:
            return .androidTV
        case .tclNative:
            return .tclNative
        case .lg:
            return .webOS
        case .philipsAndroid:
            return .androidTV
        case .philips:
            return .philipsAPI
        case .vizio:
            return .vizioAPI
        case .androidTV:
            return .androidTV
        case .toshiba:
            return .androidTV
        case .panasonic:
            return .panasonicAPI
        }
    }
}

enum TVConnectionType {
    case rokuProtocol
    case fireTVProtocol
    case smartThings
    case braviaAPI
    case webOS
    case androidTV
    case philipsAPI
    case vizioAPI
    case panasonicAPI
    case tclNative
}
