import Foundation

// MARK: - Generator Numero Telefono
class TelefonoGenerator {
    // Genera un numero di telefono mobile italiano casuale
    func generateRandomPhoneNumber() -> String {
        // Formato mobile: +393XXXXXXXXX (10 cifre dopo +39)
        let prefix = prefissiTelefono.randomElement()!
        let number = String(format: "%07d", Int.random(in: 1000000...9999999))
        return "+39\(prefix)\(number)"
    }
}

