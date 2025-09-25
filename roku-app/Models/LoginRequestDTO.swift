import Foundation

struct LoginRequestDTO: Encodable {
    let uuid: String
    let deviceModel: String
    let userDeviceName: String
    let osVersion: String
    let platform: String
    let countryCode: String
    let language: String
    let apiVersion: String

    private enum CodingKeys: String, CodingKey {
        case uuid = "uuid"
        case deviceModel = "device"
        case userDeviceName = "name"
        case osVersion = "osVersion"
        case platform = "platform"
        case countryCode = "country"
        case language = "locale"
        case apiVersion = "appVersion"
    }
}
