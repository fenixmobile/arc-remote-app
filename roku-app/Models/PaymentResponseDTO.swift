import Foundation

struct PaymentResponseDTO: Decodable {
    let success: Bool
    let message: String
    let transactionId: String?
}
