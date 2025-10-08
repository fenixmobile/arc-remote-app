//
//  FireTVPinVerifyRequestDTO.swift
//  roku-app
//
//  Created by Sengel on 8.09.2025.
//

import Foundation

struct FireTVPinVerifyRequestDTO: Encodable {
    let pin: String
    
    private enum CodingKeys: String, CodingKey {
        case pin
    }
}
