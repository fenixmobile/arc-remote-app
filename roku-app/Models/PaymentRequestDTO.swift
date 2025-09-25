import Foundation

struct PaymentRequestDTO: Encodable {
    let productId: String
    let userId: String
    let receipt: String
}
