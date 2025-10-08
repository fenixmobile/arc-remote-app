//
//  FireTVResponseDTO.swift
//  roku-app
//
//  Created by Sengel on 8.09.2025.
//

import Foundation

struct FireTVResponseDTO: Decodable {
    let description: String
    
    private enum CodingKeys: String, CodingKey {
        case description
    }
}
