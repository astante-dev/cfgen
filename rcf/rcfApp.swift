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
    let generator = CodiceFiscaleGenerator()

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
        let cf = generator.generateRandomCodiceFiscale()
        // Copia negli appunti
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(cf, forType: .string)
    }

    @objc func generateAndCopyPhoneNumber() {
        let phone = generator.generateRandomPhoneNumber()
        // Copia negli appunti
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(phone, forType: .string)
    }

    @objc func quit() {
        NSApp.terminate(nil)
    }
}

// MARK: - Generator
struct Persona {
    let nome: String
    let cognome: String
    let data: Date
    let sesso: String // "M" o "F"
    let luogoCodice: String // codice catastale es. "H501"
}

class CodiceFiscaleGenerator {
    // Mappa mese
    let meseMap: [Int: Character] = [
        1: "A", 2: "B", 3: "C", 4: "D", 5: "E", 6: "H",
        7: "L", 8: "M", 9: "P", 10: "R", 11: "S", 12: "T"
    ]

    // Tabelle per controllo (semplificate come dizionari)
    let oddMap: [Character: Int] = [
        "0":1,"1":0,"2":5,"3":7,"4":9,"5":13,"6":15,"7":17,"8":19,"9":21,
        "A":1,"B":0,"C":5,"D":7,"E":9,"F":13,"G":15,"H":17,"I":19,"J":21,
        "K":2,"L":4,"M":18,"N":20,"O":11,"P":3,"Q":6,"R":8,"S":12,"T":14,
        "U":16,"V":10,"W":22,"X":25,"Y":24,"Z":23
    ]
    let evenMap: [Character: Int] = [
        "0":0,"1":1,"2":2,"3":3,"4":4,"5":5,"6":6,"7":7,"8":8,"9":9,
        "A":0,"B":1,"C":2,"D":3,"E":4,"F":5,"G":6,"H":7,"I":8,"J":9,
        "K":10,"L":11,"M":12,"N":13,"O":14,"P":15,"Q":16,"R":17,"S":18,"T":19,
        "U":20,"V":21,"W":22,"X":23,"Y":24,"Z":25
    ]
    let controlMap: [Int: Character] = {
        var m = [Int:Character]()
        let letters = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
        for i in 0..<26 { m[i] = letters[i] }
        return m
    }()

    // small sample of comune codes (sostituisci con file ISTAT completo)
    let sampleComuni = ["H501", "F205", "B157", "L736", "G273"] // esempi: Roma, Milano ecc. (sostituisci)

    // Utility: prende consonanti poi vocali poi X se servono
    func codeFromSurname(_ s: String) -> String {
        return codeFromNamePart(s, isNome:false)
    }
    func codeFromName(_ s: String) -> String {
        return codeFromNamePart(s, isNome:true)
    }
    func codeFromNamePart(_ s: String, isNome: Bool) -> String {
        let letters = s.uppercased().filter { $0.isLetter }
        let consonants = letters.filter { !"AEIOU".contains($0) }
        let vowels = letters.filter { "AEIOU".contains($0) }
        var chars = ""
        if isNome {
            // regola nome: se consonanti >=4 prendi 1,3,4
            if consonants.count >= 4 {
                let arr = Array(consonants)
                chars = String([arr[0], arr[2], arr[3]])
            } else {
                chars = String((consonants + vowels).prefix(3))
            }
        } else {
            chars = String((consonants + vowels).prefix(3))
        }
        while chars.count < 3 { chars.append("X") }
        return chars
    }

    func yearPart(from date: Date) -> String {
        let cal = Calendar(identifier: .gregorian)
        let year = cal.component(.year, from: date) % 100
        return String(format: "%02d", year)
    }

    func monthPart(from date: Date) -> Character {
        let cal = Calendar(identifier: .gregorian)
        let m = cal.component(.month, from: date)
        return meseMap[m] ?? "X"
    }

    func dayPart(from date: Date, sesso: String) -> String {
        let cal = Calendar(identifier: .gregorian)
        var day = cal.component(.day, from: date)
        if sesso.uppercased() == "F" { day += 40 }
        return String(format: "%02d", day)
    }

    func placePart(random: Bool = true) -> String {
        // per ora random dal sample; sostituire con lookup completo
        return sampleComuni.randomElement() ?? "Z000"
    }

    func controlCharacter(for partial: String) -> Character {
        var sum = 0
        let chars = Array(partial)
        for (i, ch) in chars.enumerated() {
            let upper = ch
            if (i % 2) == 0 {
                // posizione dispari (1-based) -> i%2==0
                sum += oddMap[upper] ?? 0
            } else {
                sum += evenMap[upper] ?? 0
            }
        }
        let rem = sum % 26
        return controlMap[rem] ?? "Z"
    }

    // Genera CF da dati persona
    func generateCodiceFiscale(for p: Persona) -> String {
        let s = codeFromSurname(p.cognome)
        let n = codeFromName(p.nome)
        let y = yearPart(from: p.data)
        let m = monthPart(from: p.data)
        let d = dayPart(from: p.data, sesso: p.sesso)
        let loc = p.luogoCodice
        let partial = s + n + y + String(m) + d + loc
        let control = controlCharacter(for: partial)
        return partial + String(control)
    }

    // Genera un Persona casuale (semplificato)
    func randomPersona() -> Persona {
        let nomi = ["Luca","Marco","Anna","Giulia","Francesco","Maria","Davide","Sara"]
        let cognomi = ["Rossi","Bianchi","Ferrari","Esposito","Russo","Bruno","Gallo","Costa"]

        let nome = nomi.randomElement()!
        let cognome = cognomi.randomElement()!

        // data random tra 1940 e 2010
        var comp = DateComponents()
        comp.year = Int.random(in: 1940...2010)
        comp.month = Int.random(in: 1...12)
        let maxDay = Calendar.current.range(of: .day, in: .month, for:
            Calendar.current.date(from: DateComponents(year: comp.year!, month: comp.month!))!)!.count
        comp.day = Int.random(in: 1...maxDay)
        let date = Calendar.current.date(from: comp)!

        let sesso = Bool.random() ? "M" : "F"
        let luogo = placePart()
        return Persona(nome: nome, cognome: cognome, data: date, sesso: sesso, luogoCodice: luogo)
    }

    func generateRandomCodiceFiscale() -> String {
        let p = randomPersona()
        return generateCodiceFiscale(for: p)
    }

        // Genera un numero di telefono italiano casuale
    func generateRandomPhoneNumber() -> String {
        // Formato italiano: +39 3XX XXX XXXX (mobile) o +39 0X XXXX XXXX (fisso)
        let isMobile = Bool.random()
        
        if isMobile {
            // Mobile: +39 3XX XXX XXXX
            let prefix = ["30", "31", "32", "33", "34", "35", "36", "37", "39"].randomElement()!
            let number = String(format: "%07d", Int.random(in: 1000000...9999999))
            return "+39 \(prefix) \(String(number.prefix(3))) \(String(number.suffix(4)))"
        } else {
            // Fisso: +39 0X XXXX XXXX
            let prefix = String(format: "%02d", Int.random(in: 1...9))
            let number = String(format: "%08d", Int.random(in: 10000000...99999999))
            return "+39 0\(prefix) \(String(number.prefix(4))) \(String(number.suffix(4)))"
        }
    }

}
    
