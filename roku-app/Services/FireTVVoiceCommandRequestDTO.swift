import Foundation

struct FireTVVoiceCommandRequestDTO: Encodable {
    let action: String
    
    private enum CodingKeys: String, CodingKey {
        case action
    }
}
