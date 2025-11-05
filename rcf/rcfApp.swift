import SwiftUI
import AppKit

@main
struct CFGenApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Nessuna scena necessaria per un'app menu bar senza finestre
        Settings {
            Text("")
                .frame(width: 1, height: 1)
                .hidden()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    let cfGenerator = CodiceFiscaleGenerator()
    let telefonoGenerator = TelefonoGenerator()

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        
        statusItem = NSStatusBar.system.statusItem(withLength: 22)
        
        // Imposta l'icona del menu bar
        guard let button = statusItem.button else { return }
        
        if let image = NSImage(named: "sock") {
            image.isTemplate = true
            image.size = NSSize(width: 18, height: 18)
            button.image = image
            button.imagePosition = .imageOnly
        } else {
            button.title = "CFGen"
        }
        
        constructMenu()
        
        // Genera e copia automaticamente quando l'app viene lanciata
        generateAndCopy()
    }

    func constructMenu() {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Genera CF casuale e copia", action: #selector(generateAndCopy), keyEquivalent: "g"))
        menu.addItem(NSMenuItem(title: "Genera numero telefono casuale e copia", action: #selector(generateAndCopyPhoneNumber), keyEquivalent: "t"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Esci", action: #selector(quit), keyEquivalent: "q"))
        statusItem.menu = menu
    }

    @objc func generateAndCopy() {
        let cf = cfGenerator.generateRandomCodiceFiscale()
        // Copia negli appunti
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(cf, forType: .string)
    }

    @objc func generateAndCopyPhoneNumber() {
        let phone = telefonoGenerator.generateRandomPhoneNumber()
        // Copia negli appunti
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(phone, forType: .string)
    }

    @objc func quit() {
        NSApp.terminate(nil)
    }
}
    
