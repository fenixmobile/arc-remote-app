//
//  FireTVPinDisplayRequestDTO.swift
//  roku-app
//
//  Created by Ali İhsan Çağlayan on 8.09.2025.
//

import Foundation

struct FireTVPinDisplayRequestDTO: Encodable {
    let friendlyName: String
    
    private enum CodingKeys: String, CodingKey {
        case friendlyName
    }
}
