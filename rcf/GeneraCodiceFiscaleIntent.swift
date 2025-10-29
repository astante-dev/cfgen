import AppIntents
import AppKit

@available(macOS 13.0, *)
struct GeneraCodiceFiscaleIntent: AppIntent {
    static var title: LocalizedStringResource = "Genera Codice Fiscale Random"
    static var description = IntentDescription("Genera un codice fiscale italiano casuale e lo copia negli appunti")
    static var openAppWhenRun: Bool = false
    
    static var parameterSummary: some ParameterSummary {
        Summary("Genera codice fiscale random")
    }
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let generator = CodiceFiscaleGenerator()
        let codiceFiscale = generator.generateRandomCodiceFiscale()
        
        // Copia negli appunti
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(codiceFiscale, forType: .string)
        
        return .result(dialog: "Codice fiscale generato: \(codiceFiscale)")
    }
}

