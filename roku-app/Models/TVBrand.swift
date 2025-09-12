//
//  TVBrand.swift
//  roku-app
//
//  Created by Ali İhsan Çağlayan on 8.09.2025.
//

import Foundation

enum TVBrand: String, CaseIterable, Codable {
    case roku = "Roku TV"
    case fireTV = "Fire TV"
    case samsung = "Samsung TV"
    case sony = "Sony TV"
    case tcl = "TCL TV"
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
        switch self {
        case .roku:
            return "tv.fill"
        case .fireTV:
            return "flame.fill"
        case .samsung:
            return "s.circle.fill"
        case .sony:
            return "s.circle.fill"
        case .tcl:
            return "t.circle.fill"
        case .lg:
            return "l.circle.fill"
        case .philipsAndroid:
            return "p.circle.fill"
        case .philips:
            return "p.circle.fill"
        case .vizio:
            return "v.circle.fill"
        case .androidTV:
            return "android"
        case .toshiba:
            return "t.circle.fill"
        case .panasonic:
            return "p.circle.fill"
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
            return .rokuProtocol
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
}
