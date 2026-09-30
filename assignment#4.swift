// =============================================================
//  Station ALMA-7, Part II: The Teleporter Incident
//  iOS Mobile Development · Module 4 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Part2_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER DATA section.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • Default to struct. Use class only where the task says so.
// =============================================================


// MARK: - =================== STARTER DATA ===================
// MARK: - Do not modify anything in this section

/// Splits a line into fields.
/// fields("crate:101:120")            -> ["crate", "101", "120"]
/// fields("livestock:lab mice:12:2")  -> ["livestock", "lab mice", "12", "2"]
/// fields("junk")                     -> ["junk"]
func fields(_ line: String, separatedBy separator: Character = ":") -> [String] {
    var result: [String] = []
    var current = ""
    for character in line {
        if character == separator {
            result.append(current)
            current = ""
        } else {
            current.append(character)
        }
    }
    result.append(current)
    return result
}

/// Cargo manifest as recovered from the damaged recorder.
let rawManifest = [
    "crate:101:120",
    "container:KZ-ALM-7:340",
    "livestock:lab mice:12:2",
    "???-corrupted-line",
    "crate:102:75",
    "container:KZ-ALM-9:410",
    "livestock:ficus:3:5",
    "crate:103:260",
    "crate:104:abc",
    ""
]

/// Oxygen readings. One of these deck names is not a real deck.
let deckReadings: [(deck: String, oxygen: Int)] = [
    (deck: "bridge",     oxygen: 78),
    (deck: "lab",        oxygen: 64),
    (deck: "greenhouse", oxygen: 55),
    (deck: "cargo",      oxygen: 12),
    (deck: "medbay",     oxygen: 90),
    (deck: "engine",     oxygen: 41)
]

/// Crew records, straight from the personnel file.
let crewData: [(name: String, deck: String, oxygen: Int)] = [
    (name: "Timur",   deck: "engine", oxygen: 62),
    (name: "Dana",    deck: "lab",    oxygen: 48),
    (name: "Aigerim", deck: "bridge", oxygen: 91),
    (name: "Nurlan",  deck: "cargo",  oxygen: 17)
]

print("ALMA-7 recorder online: \(rawManifest.count) manifest lines, \(deckReadings.count) readings, \(crewData.count) crew records.")

// MARK: - ================= END OF STARTER DATA =================


// MARK: - =================== YOUR SOLUTION ===================
// Completed by Maksat Altynbek.

// MARK: Level 1 - The Deck Register

enum Deck: String, CaseIterable {
    case bridge, lab, cargo, medbay, engine

    var evacuationPriority: Int {
        switch self {
        case .bridge: return 1
        case .medbay: return 2
        case .lab: return 3
        case .engine: return 4
        case .cargo: return 5
        }
    }
}

for deck in Deck.allCases {
    print("Deck: \(deck.rawValue), priority: \(deck.evacuationPriority)")
}
print("Registered decks: \(Deck.allCases.count)")

enum AlarmLevel: Int {
    case green = 0
    case yellow, orange, red

    static func level(forTotalMass mass: Int) -> AlarmLevel {
        let step = min(max(mass / 500, 0), AlarmLevel.red.rawValue)
        return AlarmLevel(rawValue: step) ?? .green
    }
}

print("Alarm for 0 kg: \(AlarmLevel.level(forTotalMass: 0))")
print("Alarm for 940 kg: \(AlarmLevel.level(forTotalMass: 940))")
print("Alarm for 4000 kg: \(AlarmLevel.level(forTotalMass: 4000))")

// MARK: Level 2 - The Manifest

enum ManifestEntry {
    case crate(id: Int, massKg: Int)
    case container(code: String, massKg: Int)
    case livestock(species: String, count: Int, massPerUnitKg: Int)
    case unknown(raw: String)
}

func parseEntry(_ line: String) -> ManifestEntry {
    let parts = fields(line)
    guard let tag = parts.first else { return .unknown(raw: line) }

    switch tag {
    case "crate":
        guard parts.count == 3,
              let id = Int(parts[1]),
              let massKg = Int(parts[2]) else { return .unknown(raw: line) }
        return .crate(id: id, massKg: massKg)
    case "container":
        guard parts.count == 3,
              let massKg = Int(parts[2]) else { return .unknown(raw: line) }
        return .container(code: parts[1], massKg: massKg)
    case "livestock":
        guard parts.count == 4,
              let count = Int(parts[2]),
              let massPerUnitKg = Int(parts[3]) else { return .unknown(raw: line) }
        return .livestock(species: parts[1], count: count, massPerUnitKg: massPerUnitKg)
    default:
        return .unknown(raw: line)
    }
}

func mass(of entry: ManifestEntry) -> Int {
    switch entry {
    case let .crate(_, massKg): return massKg
    case let .container(_, massKg): return massKg
    case let .livestock(_, count, massPerUnitKg): return count * massPerUnitKg
    case .unknown: return 0
    }
}

var manifest: [ManifestEntry] = []
var totalManifestMass = 0
var unknownCount = 0
for line in rawManifest {
    let entry = parseEntry(line)
    manifest.append(entry)
    totalManifestMass += mass(of: entry)
    if case .unknown = entry { unknownCount += 1 }
    print("Manifest entry: \(entry), mass: \(mass(of: entry)) kg")
}
let A = totalManifestMass
print("Parsed manifest: \(manifest)")
print("Unknown lines: \(unknownCount); total mass A: \(A) kg")

// MARK: Level 3 - Crew Snapshots

struct CrewSnapshot {
    let name: String
    var deck: Deck
    var oxygen: Int

    mutating func breathe(_ amount: Int) {
        oxygen = max(0, oxygen - max(0, amount))
    }

    mutating func move(to deck: Deck) {
        self.deck = deck
    }

    mutating func reviveInMedbay() {
        self = CrewSnapshot(name: name, deck: .medbay, oxygen: 100)
    }

    static func rookie(named name: String) -> CrewSnapshot {
        return CrewSnapshot(name: name, deck: .bridge, oxygen: 100)
    }
}

var crewRoster: [CrewSnapshot] = []
for record in crewData {
    guard let deck = Deck(rawValue: record.deck) else {
        print("Warning: skipping \(record.name), unknown deck '\(record.deck)'.")
        continue
    }
    crewRoster.append(CrewSnapshot(name: record.name, deck: deck, oxygen: record.oxygen))
}
print("Crew roster: \(crewRoster)")
print("Crew count: \(crewRoster.count)")

// 3.3: A plain parameter is immutable, so mutate a local value copy.
func breathePlain(_ snapshot: CrewSnapshot, amount: Int) {
    var local = snapshot
    print("Plain function local BEFORE: \(local)")
    local.breathe(amount)
    print("Plain function local AFTER:  \(local)")
}

func breatheInPlace(_ snapshot: inout CrewSnapshot, amount: Int) {
    snapshot.breathe(amount)
}

var originalSnapshot = CrewSnapshot.rookie(named: "Demo")
var copiedSnapshot = originalSnapshot
print("Copy BEFORE: original=\(originalSnapshot), copy=\(copiedSnapshot)")
copiedSnapshot.breathe(25)
copiedSnapshot.move(to: .lab)
print("Copy AFTER:  original=\(originalSnapshot), copy=\(copiedSnapshot)")

print("Plain call BEFORE: original=\(originalSnapshot)")
breathePlain(originalSnapshot, amount: 20)
print("Plain call AFTER:  original=\(originalSnapshot)")

print("Inout call BEFORE: original=\(originalSnapshot)")
breatheInPlace(&originalSnapshot, amount: 20)
print("Inout call AFTER:  original=\(originalSnapshot)")

copiedSnapshot.breathe(500)
print("Before revival: \(copiedSnapshot)")
copiedSnapshot.reviveInMedbay()
print("After revival:  \(copiedSnapshot)")

// MARK: Level 4 - The Teleport Pod

final class TeleportPod {
    let id: String
    var chargeLevel: Int
    var occupant: CrewSnapshot?

    // Structs synthesize a memberwise initializer; classes do not.
    // This class needs an initializer to initialize id and chargeLevel.
    init(id: String, chargeLevel: Int) {
        self.id = id
        self.chargeLevel = chargeLevel
        self.occupant = nil
    }

    func load(_ crew: CrewSnapshot) -> Bool {
        guard occupant == nil, chargeLevel >= 20 else { return false }
        occupant = crew
        return true
    }

    func fire() -> CrewSnapshot? {
        guard let passenger = occupant else { return nil }
        chargeLevel -= 20
        occupant = nil
        return passenger
    }

    deinit {
        print("TeleportPod \(id) deinit")
    }
}

// 4.2: Exactly three loads/fires in the required order, then one empty fire.
let ledgerPod = TeleportPod(id: "P-1", chargeLevel: 100)
for name in ["Timur", "Dana", "Nurlan"] {
    var passenger: CrewSnapshot?
    for member in crewRoster {
        if member.name == name { passenger = member; break }
    }
    if let crew = passenger {
        let loaded = ledgerPod.load(crew)
        print("Load \(name): \(loaded); charge: \(ledgerPod.chargeLevel)")
        let arrived = ledgerPod.fire()
        print("Fire \(name): arrived=\(arrived?.name ?? "none"); charge: \(ledgerPod.chargeLevel)")
    } else {
        print("Warning: passenger \(name) missing from roster.")
    }
}
let emptyArrival = ledgerPod.fire()
print("Empty fire: arrived=\(emptyArrival?.name ?? "none"); charge: \(ledgerPod.chargeLevel)")
let C = ledgerPod.chargeLevel

// 4.3: Save C first; the following experiment deliberately changes the pod.
let aliasPod = ledgerPod
print("Class BEFORE: first=\(ledgerPod.chargeLevel), second=\(aliasPod.chargeLevel)")
aliasPod.chargeLevel = 15
print("Class AFTER:  first=\(ledgerPod.chargeLevel), second=\(aliasPod.chargeLevel)")

let firstCrew = CrewSnapshot.rookie(named: "Value demo")
var secondCrew = firstCrew
print("Struct BEFORE: first=\(firstCrew.oxygen), second=\(secondCrew.oxygen)")
secondCrew.oxygen = 15
print("Struct AFTER:  first=\(firstCrew.oxygen), second=\(secondCrew.oxygen)")
// Class assignment copies a reference to one object; struct assignment copies a value.

// MARK: Level 5 - Station Systems

final class Station {
    let callSign: String
    var oxygenByDeck: [Deck: Int]
    var hullIntegrity: Int {
        willSet {
            print("Hull transition: \(hullIntegrity) -> \(newValue)")
        }
        didSet {
            // Assigning this property directly inside its own didSet does not
            // recursively call its observers, so this clamp cannot loop forever.
            hullIntegrity = min(max(hullIntegrity, 0), 100)
        }
    }

    lazy var fullDiagnostics: String = {
        print("Running full scan...")
        return "\(self.callSign): hull=\(self.hullIntegrity), oxygen=\(self.totalOxygen), decks=\(self.oxygenByDeck.count)"
    }()

    var totalOxygen: Int {
        var total = 0
        for oxygen in oxygenByDeck.values { total += oxygen }
        return total
    }

    var averageOxygen: Int {
        get {
            guard oxygenByDeck.isEmpty == false else { return 0 }
            return totalOxygen / oxygenByDeck.count
        }
        set {
            for deck in Deck.allCases {
                if let _ = oxygenByDeck[deck] { oxygenByDeck[deck] = newValue }
            }
        }
    }

    init(callSign: String, hullIntegrity: Int,
         readings: [(deck: String, oxygen: Int)]) {
        self.callSign = callSign
        self.hullIntegrity = min(max(hullIntegrity, 0), 100)
        self.oxygenByDeck = [:]
        for reading in readings {
            guard let deck = Deck(rawValue: reading.deck) else {
                print("Warning: skipping unknown deck '\(reading.deck)'.")
                continue
            }
            self.oxygenByDeck[deck] = reading.oxygen
        }
    }
}

let station = Station(callSign: "ALMA-7", hullIntegrity: 100, readings: deckReadings)
let B = station.averageOxygen
print("Station startup: total oxygen=\(station.totalOxygen), average B=\(B)")
print("Before first diagnostics access: no full scan has run.")
print("First diagnostics: \(station.fullDiagnostics)")
print("Second diagnostics (cached): \(station.fullDiagnostics)")

do {
    let untouchedStation = Station(callSign: "NO-SCAN", hullIntegrity: 100, readings: [])
    print("Untouched diagnostics BEFORE: station=\(untouchedStation.callSign)")
    print("Untouched diagnostics AFTER: oxygen=\(untouchedStation.totalOxygen); fullDiagnostics was never read.")
}
print("NO-SCAN scope ended without a full scan.")

station.averageOxygen = 70
print("After setting average to 70: average=\(station.averageOxygen), total=\(station.totalOxygen)")
for deck in Deck.allCases {
    if let oxygen = station.oxygenByDeck[deck] {
        print("Updated \(deck.rawValue) oxygen: \(oxygen)")
    }
}

// 5.2: Clamp trap, in exactly the specified order.
station.hullIntegrity = 130
print("Hull after 130: \(station.hullIntegrity)")
station.hullIntegrity = -40
print("Hull after -40: \(station.hullIntegrity)")
station.hullIntegrity = 55
print("Hull after 55: \(station.hullIntegrity)")

// MARK: Level 6 - Incident Reports
/*
The PDF says only one report fails to compile, but both Report 3 and the
snapshot assignment in Report 4 are compile errors as written.

Report 1
Expectation: every member of roster loses 10 oxygen; Timur becomes 52.
Actual: the loop modifies a separate member value, so Timur remains 62.
Rule: CrewSnapshot is a value type; the loop variable is a copy.
Fix: mutate array elements through their indices, as shown below.

Report 2
Expectation: podB is independent, so podA keeps charge 100.
Actual: changing podB also changes podA; the printed charge is 0.
Rule: class assignment copies the reference, not the object.
Fix: initialize a separate pod and copy the occupant value if present.

Report 3
Expectation: add appends to the logbook's stored array.
Actual: it does not compile: "cannot use mutating member on immutable value:
'self' is immutable".
Rule: a struct method must be mutating to change stored properties.
Fix: declare mutating func add, and call it on a var logbook.

Report 4
Expectation: both let declarations behave alike when properties are changed.
Actual: snapshot.oxygen = 40 fails: "cannot assign to property:
'snapshot' is a 'let' constant". The pod.chargeLevel assignment is valid.
Rule: let freezes a whole struct value, including its var properties. For a
class it freezes the reference binding; the object's var properties remain mutable.
Fix: use var for snapshot. The pod binding can remain let.
*/

var correctedRoster = crewRoster
print("Report 1 BEFORE: \(correctedRoster)")
for index in correctedRoster.indices { correctedRoster[index].breathe(10) }
print("Report 1 AFTER:  \(correctedRoster)")

let independentPodA = TeleportPod(id: "A", chargeLevel: 100)
let independentPodB = TeleportPod(id: independentPodA.id, chargeLevel: independentPodA.chargeLevel)
independentPodB.occupant = independentPodA.occupant
print("Report 2 BEFORE: A=\(independentPodA.chargeLevel), B=\(independentPodB.chargeLevel)")
independentPodB.chargeLevel = 0
print("Report 2 AFTER:  A=\(independentPodA.chargeLevel), B=\(independentPodB.chargeLevel)")

struct Logbook {
    var entries: [String] = []
    mutating func add(_ entry: String) { entries.append(entry) }
}
var logbook = Logbook()
print("Report 3 BEFORE: \(logbook.entries)")
logbook.add("Incident repaired")
print("Report 3 AFTER:  \(logbook.entries)")

var fixedSnapshot = CrewSnapshot.rookie(named: "Dana")
let fixedPod = TeleportPod(id: "B", chargeLevel: 50)
print("Report 4 BEFORE: snapshot oxygen=\(fixedSnapshot.oxygen), pod charge=\(fixedPod.chargeLevel)")
fixedSnapshot.oxygen = 40
fixedPod.chargeLevel = 10
print("Report 4 AFTER:  snapshot oxygen=\(fixedSnapshot.oxygen), pod charge=\(fixedPod.chargeLevel)")

// MARK: Level 7 - Sealing the Black Box

// internal blocks use of this type from other modules.
internal final class FlightRecorder {
    // private blocks all direct access to the stored entries from outside this type.
    private var entries: [String] = []

    // internal permits module reads; private(set) blocks outside writes, including unsealing.
    internal private(set) var isSealed = false

    // internal blocks construction from other modules.
    internal init() { }

    // internal blocks reads from other modules; a read-only count exposes no mutable array.
    internal var entryCount: Int { entries.count }

    // internal blocks reads from other modules; the returned String cannot change storage.
    internal var transcript: String { formattedTranscript() }

    // internal blocks calls from other modules; the guard blocks appending after sealing.
    @discardableResult
    internal func add(_ entry: String) -> Bool {
        guard isSealed == false else { return false }
        entries.append(entry)
        return true
    }

    // internal blocks calls from other modules; no method is provided to undo sealing.
    internal func seal() { isSealed = true }

    // fileprivate blocks calls from other files but permits the free audit function below.
    fileprivate func formattedTranscript() -> String {
        var lines: [String] = []
        for index in entries.indices {
            lines.append("\(index + 1). \(entries[index])")
        }
        return lines.joined(separator: "\n")
    }
}

// internal blocks calls from other modules; this free function can access the file helper.
internal func auditTranscript(of recorder: FlightRecorder) -> String {
    return recorder.formattedTranscript()
}

let recorder = FlightRecorder()
print("Recorder BEFORE: count=\(recorder.entryCount), sealed=\(recorder.isSealed)")
print("Add first entry: \(recorder.add("Manifest rebuilt"))")
print("Add second entry: \(recorder.add("Crew transfer verified"))")
print("Transcript:\n\(recorder.transcript)")
recorder.seal()
print("Attempt add after seal: \(recorder.add("Rewrite history"))")
print("Recorder AFTER: count=\(recorder.entryCount), sealed=\(recorder.isSealed)")
print("Audit transcript:\n\(auditTranscript(of: recorder))")

// Failed outside attacks, checked separately with the Swift compiler:
// recorder.entries = []
// error: 'entries' is inaccessible due to 'private' protection level
// recorder.entries.removeAll()
// error: 'entries' is inaccessible due to 'private' protection level
// recorder.isSealed = false
// error: cannot assign to property: 'isSealed' setter is inaccessible
// recorder.add("Rewrite history") is legal to call, but returns false after seal().

// MARK: Finale - Integrity Code

let D = AlarmLevel.level(forTotalMass: A).rawValue
let integrityCode = "\(A)-\(B)-\(C)-\(D)"
print("INTEGRITY CODE: \(integrityCode)")

// MARK: Bonus - ARC, deinit, and identity

var retainedPod: TeleportPod?
print("Bonus: before entering do block")
do {
    let temporaryPod = TeleportPod(id: "LIFETIME", chargeLevel: 100)
    retainedPod = temporaryPod
    print("Bonus: inside block; second reference retained")
    print("Bonus: before leaving block; pod=\(temporaryPod.id)")
}
print("Bonus: after leaving block; retained pod=\(retainedPod?.id ?? "none")")
print("Bonus: next line releases the final strong reference")
retainedPod = nil // BONUS RELEASE: deinit prints here, between the surrounding messages.
print("Bonus: after final reference release")
// The do block's local reference is gone, but the outer optional kept the pod alive.
// Assigning nil above releases the last strong reference, so ARC destroys the pod.

func samePod(_ first: TeleportPod, _ second: TeleportPod) -> Bool {
    return first === second
}
let identityPod = TeleportPod(id: "IDENTITY", chargeLevel: 80)
let sameReference = identityPod
let equalContentsPod = TeleportPod(id: "IDENTITY", chargeLevel: 80)
print("Same pod through two references: \(samePod(identityPod, sameReference))")
print("Separate pods with equal initial contents: \(samePod(identityPod, equalContentsPod))")
// Both separate pods have the same id, charge and nil occupant, but different identity.
// CrewSnapshot is a value, so it has no class-instance identity for === to compare.

// MARK: - ================= DEFENSE QUESTIONS =================
/*
1. Why did CrewSnapshot get an initializer for free and TeleportPod did not?
   A struct without a custom initializer gets a synthesized memberwise initializer,
   here CrewSnapshot(name:deck:oxygen:). Classes do not synthesize memberwise
   initializers. TeleportPod needs its explicit init to initialize its stored state.
   Classes can get a default no-argument initializer when all properties have
   defaults and the other synthesis conditions hold; that is not this case.

2. What does mutating do to self, and why do classes never need it?
   It allows a struct method to change the value of self, including assigning a
   completely new instance, as reviveInMedbay does. A class method changes the
   object reached through self; the reference binding does not need replacement.
   mutating is for value types and is not used on class instance methods.

3. In Report 4 both values are let. What exactly does let freeze?
   For a struct, the entire bound value is constant, so even oxygen declared var
   cannot be changed through that binding. For a class, let fixes which object
   the reference points to. Its var chargeLevel can still change, but the binding
   cannot be assigned a different pod. A class's let id still cannot change.

4. Why must a lazy property be var? When does lazy change behaviour?
   Its initial value is stored on the first access, after initialization has
   already finished. This deferred write requires var. Our fullDiagnostics prints
   only when first read. If never read, the scan and its side effect never happen.
   If oxygen changes before first access, the string captures that later oxygen;
   subsequent accesses keep the cached string even if oxygen changes again.

5. private vs fileprivate: where would private be too strict?
   formattedTranscript() must be callable by auditTranscript(of:), which is a free
   function outside FlightRecorder but in this same file. private would reject
   that call; fileprivate permits it while blocking calls from other files.
   The stored entries remain private because no outside code needs direct access.

Bonus. On which line does deinit fire, and why not use === on CrewSnapshot?
   The LIFETIME pod's deinit runs when retainedPod = nil (the BONUS RELEASE line)
   releases its final strong reference. It does not run when the do block ends,
   because retainedPod is still a strong owner. === compares class-instance
   identity. CrewSnapshot is a struct copied by value and has no such identity.
   Equality of struct contents would instead use == with Equatable conformance.

Why the three classes are appropriate:
   TeleportPod represents one shared physical pod, Station holds shared live state,
   and FlightRecorder has one shared append/seal history. The assignment requires
   those classes. CrewSnapshot and Logbook store independent values, so are structs.
*/
