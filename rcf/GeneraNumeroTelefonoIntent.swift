import AppIntents
import AppKit

@available(macOS 13.0, *)
struct GeneraNumeroTelefonoIntent: AppIntent {
    static var title: LocalizedStringResource = "Genera Numero di Telefono Random"
    static var description = IntentDescription("Genera un numero di telefono italiano casuale e lo copia negli appunti")
    static var openAppWhenRun: Bool = false
    
    static var parameterSummary: some ParameterSummary {
        Summary("Genera numero di telefono random")
    }
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let generator = CodiceFiscaleGenerator()
        let numeroTelefono = generator.generateRandomPhoneNumber()
        
        // Copia negli appunti
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(numeroTelefono, forType: .string)
        
        return .result(dialog: "Numero di telefono generato: \(numeroTelefono)")
    }
}

