// =============================================================
//  Station ALMA-7, Part III: The Repair Fleet
//  iOS Mobile Development · Module 5 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Part3_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER DATA section. LegacyBeacon in
//     particular must be reached with an extension, not edited.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • The Health Rule must exist in exactly ONE place in this file.
// =============================================================


// MARK: - =================== STARTER DATA ===================
// MARK: - Do not modify anything in this section

/// Drone records recovered from the fleet registry.
/// One `kind` does not correspond to any drone type you will build.
let fleetData: [(kind: String, id: String, charge: Int)] = [
    (kind: "welder",  id: "W-1", charge: 80),
    (kind: "scanner", id: "S-1", charge: 45),
    (kind: "cargo",   id: "C-1", charge: 100),
    (kind: "welder",  id: "W-2", charge: 15),
    (kind: "scanner", id: "S-2", charge: 60),
    (kind: "tug",     id: "T-1", charge: 50)
]

/// Hull sensors. These are NOT drones — they never move and never work a shift.
let sensorData: [(id: String, charge: Int)] = [
    (id: "hull-cam", charge: 12),
    (id: "thermal",  charge: 77)
]

/// Hardware from the original station. You may not add anything to this
/// declaration — no methods, no protocols, no properties.
struct LegacyBeacon {
    let name: String
    let signalStrength: Int
}

let beacon = LegacyBeacon(name: "ALMA-BEACON", signalStrength: 8)

print("Fleet registry online: \(fleetData.count) drone records, \(sensorData.count) sensors, beacon \(beacon.name).")

// MARK: - ================= END OF STARTER DATA =================


// MARK: - =================== YOUR SOLUTION ===================
// Uncomment each declaration when you start working on it.


// MARK: Level 1 · The Power Cell


final class PowerCell: Rechargeable {
    private var charge: Int

    init(charge: Int) {
        self.charge = Self.clampedCharge(charge)
    }

    func level() -> Int { charge }

    func spend(_ amount: Int) -> Bool {
        guard amount > 0, amount <= charge else { return false }
        charge -= amount
        return true
    }

    func recharge(by amount: Int) {
        charge = Self.rechargedLevel(charge, by: amount)
    }
}

let cell = PowerCell(charge: 120)
print("Cell starts clamped: \(cell.level())")
print("Spend 25: \(cell.spend(25)); remaining: \(cell.level())")
print("Spend 0: \(cell.spend(0)); remaining: \(cell.level())")
print("Spend -5: \(cell.spend(-5)); remaining: \(cell.level())")
print("Spend too much: \(cell.spend(90)); remaining: \(cell.level())")
cell.recharge(by: -10)
print("After negative recharge: \(cell.level())")
cell.recharge(by: 50)
print("After recharge, capped at 100: \(cell.level())")



// MARK: Level 2 - The Fleet


protocol PoweredTask {
    var cell: PowerCell { get }
    var powerCost: Int { get }
    func performTask() -> Int
}

extension PoweredTask {
    fileprivate func powerStatus(for id: String) -> String {
        "\(id): \(cell.level())% \(cell.level().powerBar)"
    }

    fileprivate func executePoweredTask() -> Int {
        guard cell.spend(powerCost) else { return 0 }
        return performTask()
    }
}


struct DroneSpecification {
    let cost: Int
    let work: Int
    static let welder = DroneSpecification(cost: 25, work: 40)
    static let scanner = DroneSpecification(cost: 10, work: 15)
    static let cargo = DroneSpecification(cost: 20, work: 25)
}

class Drone: PoweredTask {
    let id: String
    let cell: PowerCell

    init(id: String, cell: PowerCell) {
        self.id = id
        self.cell = cell
    }

    var powerCost: Int { 10 }

    var statusLine: String { powerStatus(for: id) }

    func performTask() -> Int { 0 }

    
    final func runOnce() -> Int {
        return executePoweredTask()
    }
}

final class WelderDrone: Drone {
    override var powerCost: Int { DroneSpecification.welder.cost }
    override func performTask() -> Int { DroneSpecification.welder.work }
    func weldSeam() -> String { "\(id): seam welded" }
}

class ScannerDrone: Drone {
    override var powerCost: Int { DroneSpecification.scanner.cost }
    override func performTask() -> Int { DroneSpecification.scanner.work }
    override var statusLine: String { super.statusLine + " [scanner]" }
}

final class CargoDrone: Drone {
    override var powerCost: Int { DroneSpecification.cargo.cost }
    override func performTask() -> Int { DroneSpecification.cargo.work }
}

func makeDrone(kind: String, id: String, charge: Int) -> Drone? {
    let battery = PowerCell(charge: charge)
    switch kind {
    case "welder": return WelderDrone(id: id, cell: battery)
    case "scanner": return ScannerDrone(id: id, cell: battery)
    case "cargo": return CargoDrone(id: id, cell: battery)
    default: return nil
    }
}

var fleet: [Drone] = []
for record in fleetData {
    guard let drone = makeDrone(kind: record.kind, id: record.id, charge: record.charge) else {
        print("Warning: skipped \(record.id), unknown drone kind '\(record.kind)'.")
        continue
    }
    fleet.append(drone)
}
print("Fleet before shift:")
for drone in fleet { print(drone.statusLine) }

// MARK: Level 3 - The Shift

func runShift(_ fleet: [Drone], rounds: Int) -> Int {
    guard rounds > 0 else { return 0 }
    var totalWork = 0
    for _ in 0..<rounds {
        for drone in fleet {
            totalWork += drone.runOnce()
        }
    }
    return totalWork
}

let A = runShift(fleet, rounds: 3)
var remainingCharge = 0
var readyCount = 0
print("Fleet after three rounds:")
for drone in fleet {
    print(drone.statusLine)
    remainingCharge += drone.cell.level()
    if drone.cell.level() >= drone.powerCost { readyCount += 1 }
}
let B = remainingCharge
let C = readyCount
print("Work A: \(A)")
print("Remaining drone charge B: \(B)")
print("Drones ready for one more task C: \(C)")

// MARK: Level 4 - Diagnostics

protocol Diagnosable {
    var componentID: String { get }
    var statusCode: Int { get }
    func diagnose() -> String
}

protocol Rechargeable {
    mutating func recharge(by amount: Int)
}


extension Rechargeable {
    static func clampedCharge(_ level: Int) -> Int {
        return min(max(level, 0), 100)
    }

    static func rechargedLevel(_ level: Int, by amount: Int) -> Int {
        guard amount > 0 else { return level }
        let current = clampedCharge(level)
        return current + min(amount, 100 - current)
    }
}

extension Drone: Diagnosable, Rechargeable {
    var componentID: String { id }
    var statusCode: Int { healthCode(for: cell.level()) }

    func recharge(by amount: Int) { cell.recharge(by: amount) }
}

struct SensorModule: Diagnosable, Rechargeable {
    let componentID: String
    var chargeLevel: Int

    init(componentID: String, chargeLevel: Int) {
        self.componentID = componentID
        self.chargeLevel = Self.clampedCharge(chargeLevel)
    }

    var statusCode: Int { healthCode(for: chargeLevel) }

    mutating func recharge(by amount: Int) {
        chargeLevel = Self.rechargedLevel(chargeLevel, by: amount)
    }
}

var sensors: [SensorModule] = []
for record in sensorData {
    sensors.append(SensorModule(componentID: record.id, chargeLevel: record.charge))
}

func diagnosticsReport(_ components: [Diagnosable]) -> String {
    var lines: [String] = []
    for component in components { lines.append(component.diagnose()) }
    return lines.joined(separator: "\n")
}


var components: [Diagnosable] = []
for drone in fleet { components.append(drone) }
for sensor in sensors { components.append(sensor) }
print("Diagnostics: drones and sensors\n\(diagnosticsReport(components))")


let rechargeDemoDrone = ScannerDrone(id: "RECHARGE-DEMO", cell: PowerCell(charge: 10))
print("Class recharge BEFORE: \(rechargeDemoDrone.statusLine)")
rechargeDemoDrone.recharge(by: 25)
print("Class recharge AFTER:  \(rechargeDemoDrone.statusLine)")
var rechargeDemoSensor = SensorModule(componentID: "SENSOR-DEMO", chargeLevel: 10)
print("Struct recharge BEFORE: \(rechargeDemoSensor.chargeLevel)")
rechargeDemoSensor.recharge(by: 25)
print("Struct recharge AFTER:  \(rechargeDemoSensor.chargeLevel)")

// MARK: Level 5 - Shared Behaviour

extension Diagnosable {
    func diagnose() -> String { "\(componentID): code \(statusCode)" }


    func healthCode(for level: Int) -> Int {
        if level < 20 { return 2 }
        if level < 50 { return 1 }
        return 0
    }
}

extension LegacyBeacon: Diagnosable {
    var componentID: String { name }
    var statusCode: Int { healthCode(for: signalStrength) }
    func diagnose() -> String {
        "LEGACY BEACON \(componentID): signal \(signalStrength), code \(statusCode)"
    }
}

components.append(beacon)
print("Diagnostics: drones, sensors and legacy beacon\n\(diagnosticsReport(components))")
var statusTotal = 0
for component in components { statusTotal += component.statusCode }
let D = statusTotal
print("Sum of component status codes D: \(D)")

extension Int {
    var powerBar: String {
        let filled = Swift.min(Swift.max(self / 10, 0), 10)
        var result = ""
        for index in 0..<10 { result += index < filled ? "#" : "." }
        return result
    }
}
print("Power bars: 42=\(42.powerBar), -5=\((-5).powerBar), 250=\(250.powerBar)")

// MARK: Level 6 - Incident Reports
/*
The PDF says two reports fail to compile. As written, Reports 1, 2 AND 3 fail;
only Report 4 compiles and prints an unexpected result. The fixes below compile.

Report 1
Expectation: PatchDrone provides its own work amount of 30.
Actual: compile error: overriding declaration requires an 'override' keyword.
Rule: a subclass must explicitly mark an implementation that overrides a member.
Fix: add override to performTask(), as in PatchDrone below.

Report 2
Expectation: subclass WelderDrone and return 999 from runOnce().
Actual: compile errors: inheritance from a final class 'WelderDrone', and
instance method overrides a 'final' instance method.
Rule: a final class cannot be subclassed, and a final method cannot be overridden.
Fix: derive HeavyWelder directly from Drone and customize cost/work only.
The inherited final runOnce() still enforces spending before work.

Report 3
Expectation: first.weldSeam() works because the stored object is a WelderDrone.
Actual: compile error: value of type 'Drone' has no member 'weldSeam'.
Rule: available members are checked using the expression's static type, Drone.
Fix: conditionally downcast with as? WelderDrone and unwrap using if let.
The cast returns an optional because a Drone reference may contain a different subclass.

Report 4
Expectation: a Labelled element containing a Thruster prints "thruster T-1".
Actual in the original: it prints "generic component".
Rule: label() was only an extension method, not a protocol requirement; a call
through Labelled selects that extension implementation using the static type.
Fix: add func label() -> String to the protocol. Its implementation is then
selected through the conformance, so Thruster's implementation is used.
*/

class PatchDrone: Drone {
    override func performTask() -> Int { 30 }
}
let patchDrone = PatchDrone(id: "PATCH", cell: PowerCell(charge: 20))
print("Report 1 fixed work: \(patchDrone.runOnce()); charge: \(patchDrone.cell.level())")

final class HeavyWelder: Drone {
    override var powerCost: Int { DroneSpecification.welder.cost }
    override func performTask() -> Int { 999 }
}
let heavyWelder = HeavyWelder(id: "HEAVY", cell: PowerCell(charge: 25))
print("Report 2 fixed work: \(heavyWelder.runOnce()); charge: \(heavyWelder.cell.level())")
print("Report 2 empty battery work: \(heavyWelder.runOnce())")

let reportFleet: [Drone] = [WelderDrone(id: "W-9", cell: PowerCell(charge: 100))]
if let first = reportFleet.first, let welder = first as? WelderDrone {
    print("Report 3 fixed: \(welder.weldSeam())")
}

protocol Labelled {
    var componentID: String { get }
    func label() -> String // This added requirement fixes the dispatch.
}
extension Labelled {
    func label() -> String { "generic component" }
}
struct Thruster: Labelled {
    let componentID: String
    func label() -> String { "thruster \(componentID)" }
}
let parts: [Labelled] = [Thruster(componentID: "T-1")]
for part in parts { print("Report 4 fixed: \(part.label())") }

// MARK: Finale - Mission Code

let missionCode = "\(A)-\(B)-\(C)-\(D)"
print("MISSION CODE: \(missionCode)")

// MARK: Bonus - Abstraction and a protocol-based fleet
// The required Drone class above remains unchanged in behaviour: a bare Drone
// returns zero work. These are separate alternatives, so the bonus does not
// replace or break the required main solution.

// Bonus 1a: runtime enforcement. This base class is used only to demonstrate
// class inheritance and rejecting construction of the base itself.
class RuntimeAbstractDrone: Drone {
    override init(id: String, cell: PowerCell) {
        super.init(id: id, cell: cell)
        if type(of: self) == RuntimeAbstractDrone.self {
            fatalError("Create a concrete drone subclass, not RuntimeAbstractDrone")
        }
    }
}
final class RuntimeWelder: RuntimeAbstractDrone {
    override var powerCost: Int { DroneSpecification.welder.cost }
    override func performTask() -> Int { DroneSpecification.welder.work }
}
let runtimeWelder = RuntimeWelder(id: "RUNTIME-W", cell: PowerCell(charge: 50))
print("Bonus runtime alternative, concrete subclass: \(runtimeWelder.runOnce()) work")


// Bonus 1b and 2: a protocol cannot be constructed, so misuse fails at compile time.
protocol RepairDrone: PoweredTask, Diagnosable, Rechargeable {
    var id: String { get }
    var statusLine: String { get }
    func runOnce() -> Int
}

extension RepairDrone {
    var componentID: String { id }
    var statusCode: Int { healthCode(for: cell.level()) }
    var statusLine: String { powerStatus(for: id) }
    func runOnce() -> Int { executePoweredTask() }
    func recharge(by amount: Int) { cell.recharge(by: amount) }

}


struct ProtocolFleet {
    struct WelderDrone: RepairDrone {
        let id: String
        let cell: PowerCell
        var powerCost: Int { DroneSpecification.welder.cost }
        func performTask() -> Int { DroneSpecification.welder.work }
        func weldSeam() -> String { "\(id): seam welded" }
    }

    struct ScannerDrone: RepairDrone {
        let id: String
        let cell: PowerCell
        var powerCost: Int { DroneSpecification.scanner.cost }
        func performTask() -> Int { DroneSpecification.scanner.work }
        var statusLine: String {
            powerStatus(for: id) + " [scanner]"
        }
    }

    struct CargoDrone: RepairDrone {
        let id: String
        let cell: PowerCell
        var powerCost: Int { DroneSpecification.cargo.cost }
        func performTask() -> Int { DroneSpecification.cargo.work }
    }

    static func makeDrone(kind: String, id: String, charge: Int) -> RepairDrone? {
        let battery = PowerCell(charge: charge)
        switch kind {
        case "welder": return WelderDrone(id: id, cell: battery)
        case "scanner": return ScannerDrone(id: id, cell: battery)
        case "cargo": return CargoDrone(id: id, cell: battery)
        default: return nil
        }
    }
}



var protocolFleet: [RepairDrone] = []
for record in fleetData {
    if let drone = ProtocolFleet.makeDrone(kind: record.kind, id: record.id, charge: record.charge) {
        protocolFleet.append(drone)
    } else {
        print("Bonus: skipped unsupported kind '\(record.kind)'.")
    }
}
print("Bonus protocol fleet, one demonstration round:")
for drone in protocolFleet {
    let work = drone.runOnce()
    print("\(drone.statusLine); work=\(work); \(drone.diagnose())")
}

// A struct containing a class reference still shares that referenced battery on copy.
let valueWelder = ProtocolFleet.WelderDrone(id: "STRUCT-W", cell: PowerCell(charge: 80))
let copiedWelder = valueWelder
print("Bonus struct copy BEFORE: original=\(valueWelder.cell.level()), copy=\(copiedWelder.cell.level())")
let copiedWork = copiedWelder.runOnce()
print("Bonus struct copy AFTER: original=\(valueWelder.cell.level()), copy=\(copiedWelder.cell.level()), work=\(copiedWork)")
/*
Bonus comparison (three sentences):
I would keep the class design for this station because each physical drone has
shared identity and final runOnce() guarantees the common spending sequence.
The protocol design lets independent struct types join the fleet, but an extension
cannot make runOnce() final, and copying these structs still shares their PowerCell.
If independent snapshots were needed I would use a value-type battery with mutating
methods, while shared mutable state calls for an explicit reference such as PowerCell
or a shared state object.
*/

// MARK: - ================= DEFENSE QUESTIONS =================
/*
1. Why can Drone satisfy a mutating protocol requirement without mutating?
   mutating permits a value type to change self or its stored properties.
   SensorModule replaces its stored chargeLevel, so its method needs mutating.
   Drone is a class: recharge changes the referenced battery without replacing
   the caller's reference. Class methods do not use the mutating keyword.

2. One thing inheritance does that protocols cannot, and vice versa:
   A subclass inherits stored state, initialization behaviour and overridable
   implementations from a superclass. A protocol cannot supply inherited stored
   instance properties; it only requires capabilities, with extension defaults.
   A protocol can unite unrelated classes and structs in [Diagnosable], and one
   type can conform to several protocols. A class has only one superclass, and
   a struct cannot inherit from a class.

3. What does final prevent, and what does it protect in runOnce()?
   final class blocks subclassing; final on a member blocks overriding it.
   final runOnce() stops subclasses replacing the spend-before-work sequence.
   They customize powerCost and performTask(), while failure to spend always
   returns zero and never calls performTask(). It protects this entry point;
   performTask() remains callable directly because the assignment exposes it.

4. Why did the extension's label() win in the original Report 4?
   The original Labelled protocol did not require label(). The call through
   a Labelled value therefore used the extension-only method selected from the
   static type, even though the concrete Thruster had a same-named method.
   Adding label() to the protocol makes it a requirement, and Thruster's method
   becomes its conformance implementation, used through [Labelled] as well.
*/
