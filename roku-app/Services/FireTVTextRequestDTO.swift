import Foundation

struct FireTVTextRequestDTO: Encodable {
    let text: String
    
    private enum CodingKeys: String, CodingKey {
        case text
    }
}
