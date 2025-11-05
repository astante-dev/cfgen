import AppIntents

@available(macOS 14.0, *)
struct AppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        return [
            AppShortcut(
                intent: GeneraCodiceFiscaleIntent(),
                phrases: [
                    "fai codice fiscale random con ${applicationName}",
                    "genera codice fiscale random con ${applicationName}",
                    "crea codice fiscale random con ${applicationName}"
                ],
                shortTitle: "Codice Fiscale Random",
                systemImageName: "doc.text"
            ),
            AppShortcut(
                intent: GeneraNumeroTelefonoIntent(),
                phrases: [
                    "numero di telefono random con ${applicationName}",
                    "genera numero di telefono random con ${applicationName}",
                    "crea numero di telefono random con ${applicationName}",
                    "fai numero di telefono random con ${applicationName}"
                ],
                shortTitle: "Numero Telefono Random",
                systemImageName: "phone"
            )
        ]
    }
    
    static var shortcutTileColor: ShortcutTileColor = .blue
}
