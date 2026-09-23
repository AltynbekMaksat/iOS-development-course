// =============================================================
//  Station ALMA-7: Rescue Protocol
//  iOS Mobile Development · Module 3 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER CODE section.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • Use the exact function names from the assignment PDF.
// =============================================================


// MARK: - =================== STARTER CODE ===================
// MARK: - Do not modify anything in this section

typealias Reading = (sensor: String, value: Int)

/// Splits a string at the first occurrence of the separator.
/// splitOnce("O2:87", by: ":") -> ("O2", "87")
/// splitOnce("hello", by: ":") -> nil
func splitOnce(_ line: String, by separator: Character) -> (String, String)? {
    guard let index = line.firstIndex(of: separator) else { return nil }
    let left = String(line[..<index])
    let right = String(line[line.index(after: index)...])
    return (left, right)
}

let rawLog = [
    "O2:87", "TEMP:-12", "O2:9x", "PRESS:101", "TEMP:abc", "O2:",
    "RAD:3", "O2:64", ":55", "TEMP:31", "PRESS:98", "O2:71",
    "RAD:-1", "TEMP:4", "PRESS:1o2", "O2:90"
]

class Tank {
    var level: Int
    init(level: Int) { self.level = level }
}

class Module {
    let name: String
    var oxygenTank: Tank?
    init(name: String, oxygenTank: Tank?) {
        self.name = name
        self.oxygenTank = oxygenTank
    }
}

class CrewMember {
    let name: String
    let role: String
    let priority: Int      // 1 = evacuated first
    var module: Module?    // nil = in open space
    init(name: String, role: String, priority: Int, module: Module?) {
        self.name = name
        self.role = role
        self.priority = priority
        self.module = module
    }
}

let lab  = Module(name: "Lab",  oxygenTank: Tank(level: 40))
let hab  = Module(name: "Hab",  oxygenTank: Tank(level: 12))
let dock = Module(name: "Dock", oxygenTank: nil)

let crew = [
    CrewMember(name: "Timur",   role: "Engineer",  priority: 3, module: lab),
    CrewMember(name: "Dana",    role: "Scientist", priority: 4, module: dock),
    CrewMember(name: "Aigerim", role: "Commander", priority: 1, module: hab),
    CrewMember(name: "Nurlan",  role: "Pilot",     priority: 2, module: nil)
]

var roster: [String: CrewMember] = [:]
for member in crew { roster[member.name] = member }

print("ALMA-7 systems online: \(rawLog.count) log lines, \(crew.count) crew members.")

// MARK: - ================= END OF STARTER CODE =================


// MARK: - =================== YOUR SOLUTION ===================
// Uncomment each signature when you start working on it.


// MARK: Level 1 · Decoding Telemetry

// 1.1
func parseReading(_ raw: String) -> Reading? {
    guard let (sensor, valueString) = splitOnce(raw, by: ":"),
          !sensor.isEmpty,
          let value = Int(valueString),
          value >= 0 || sensor == "TEMP" else {
        return nil
    }
    return (sensor: sensor, value: value)
}

// Тесты
print(parseReading("O2:87") as Any)
print(parseReading("TEMP:-12") as Any)
print(parseReading("RAD:-1") as Any)
print(parseReading(":55") as Any)

// 1.2
func parseLog(_ lines: [String]) -> (valid: [Reading], invalidCount: Int) {
    var validReadings: [Reading] = []
    var invalidCount = 0

    for line in lines {
        if let reading = parseReading(line) {
            validReadings.append(reading)
        } else {
            invalidCount += 1
        }
    }

    return (valid: validReadings, invalidCount: invalidCount)
}

// Тесты
let logResult = parseLog(rawLog)
print(logResult.valid)
print(logResult.invalidCount)

let A = logResult.invalidCount
print("A = \(A)")



// MARK: Level 2 · Analysis

// 2.1
func select(_ readings: [Reading], where isIncluded: (Reading) -> Bool) -> [Reading] {
    var result: [Reading] = []
    for reading in readings {
        if isIncluded(reading) {
            result.append(reading)
        }
    }
    return result
}

func values(of readings: [Reading]) -> [Int] {
    var result: [Int] = []
    for reading in readings {
        result.append(reading.value)
    }
    return result
}

// Тесты
let validReadings = parseLog(rawLog).valid

let o2Readings = select(validReadings) { $0.sensor == "O2" }
print(o2Readings)

let o2Values = values(of: o2Readings)
print(o2Values)

// 2.2
func stats(of values: [Int]) -> (min: Int, max: Int, average: Double)? {
    guard let first = values.first else {
        return nil
    }

    var minValue = first
    var maxValue = first
    var sum = 0

    for value in values {
        if value < minValue {
            minValue = value
        }
        if value > maxValue {
            maxValue = value
        }
        sum += value
    }

    let average = Double(sum) / Double(values.count)
    return (min: minValue, max: maxValue, average: average)
}

func stats(_ values: Int...) -> (min: Int, max: Int, average: Double)? {
    stats(of: values)
}

// Тесты
print(stats(3, 8, 1) as Any)
print(stats() as Any)
print(stats(of: o2Values) as Any)

let B: Int
if let o2Stats = stats(of: o2Values) {
    B = Int(o2Stats.average)
} else {
    B = 0
}
print("B = \(B)")

//2.3

// 1. Полная форма с типами и return
let sorted1 = validReadings.sorted(by: { (a: Reading, b: Reading) -> Bool in
    return a.value > b.value
})

// 2. Типы выводятся из контекста
let sorted2 = validReadings.sorted(by: { (a, b) in
    return a.value > b.value
})

// 3. убираем слово return
let sorted3 = validReadings.sorted(by: { (a, b) in a.value > b.value })

// 4. Сокращённые имена аргументов $0, $1
let sorted4 = validReadings.sorted(by: { $0.value > $1.value })

// 5. Trailing closure
let sorted5 = validReadings.sorted { $0.value > $1.value }


print(sorted1)

func readingsEqual(_ a: [Reading], _ b: [Reading]) -> Bool {
    guard a.count == b.count else { return false }
    for i in 0..<a.count {
        if a[i].sensor != b[i].sensor || a[i].value != b[i].value {
            return false
        }
    }
    return true
}

let allMatch = readingsEqual(sorted1, sorted2)
    && readingsEqual(sorted2, sorted3)
    && readingsEqual(sorted3, sorted4)
    && readingsEqual(sorted4, sorted5)

print("All five sorts match: \(allMatch)")


// MARK: Level 3 · Temperature Stabilization

// 3.1
func heatUp(_ t: Int) -> Int {
    return t + 5
}

func coolDown(_ t: Int) -> Int {
    return t - 3
}

func hold(_ t: Int) -> Int {
    return t
}

func chooseProtocol(for temp: Int) -> (Int) -> Int {
    if temp < 18 {
        return heatUp
    } else if temp > 24 {
        return coolDown
    } else {
        return hold
    }
}

// Тесты
print(heatUp(20))
print(coolDown(20))
print(hold(20))

let protocol1 = chooseProtocol(for: 10)
print(protocol1(10))

let protocol2 = chooseProtocol(for: 30)
print(protocol2(30))

let protocol3 = chooseProtocol(for: 20)
print(protocol3(20))

// 3.2
func runUntilStable(from start: Int, maxSteps: Int = 10) -> (finalTemp: Int, steps: Int, isStable: Bool) {
    var temp = start
    var steps = 0

    while (temp < 18 || temp > 24) && steps < maxSteps {
        let protocolToApply = chooseProtocol(for: temp)
        temp = protocolToApply(temp)
        steps += 1
    }

    let isStable = temp >= 18 && temp <= 24
    return (finalTemp: temp, steps: steps, isStable: isStable)
}

// Тесты
print(runUntilStable(from: 31))


print(runUntilStable(from: -100, maxSteps: 5))


let tempReadings = select(validReadings) { $0.sensor == "TEMP" }
let tempValues = values(of: tempReadings)

let C: Int
if let tempStats = stats(of: tempValues) {
    C = runUntilStable(from: tempStats.min).steps
} else {
    C = 0
}
print("C = \(C)")

// MARK: Level 4 · The Crew

// 4.1
func oxygenLevel(of member: CrewMember) -> Int? {
    return member.module?.oxygenTank?.level
}

// Тесты
if let timur = roster["Timur"] {
    print(oxygenLevel(of: timur) as Any)
}

if let dana = roster["Dana"] {
    print(oxygenLevel(of: dana) as Any)
}

if let aigerim = roster["Aigerim"] {
    print(oxygenLevel(of: aigerim) as Any)
}

if let nurlan = roster["Nurlan"] {
    print(oxygenLevel(of: nurlan) as Any)
}

// 4.2
func status(of member: CrewMember) -> String {
    guard let level = oxygenLevel(of: member) else {
        let location = member.module?.name ?? "open space"
        return "\(member.name): no data (\(location))"
    }

    let condition = level < 20 ? "CRITICAL" : "OK"
    return "\(member.name): \(level)% \(condition)"
}

// Тесты
for member in crew {
    print(status(of: member))
}

// 4.3
@discardableResult
func transferOxygen(from source: inout Int, to target: inout Int, amount: Int) -> Int {
    guard amount > 0 else {
        return 0
    }

    let availableToTake = min(amount, source)
    let spaceInTarget = 100 - target
    let actualTransfer = min(availableToTake, spaceInTarget)

    guard actualTransfer > 0 else {
        return 0
    }

    source -= actualTransfer
    target += actualTransfer

    return actualTransfer
}

// Тест:
guard let labTank = lab.oxygenTank, let habTank = hab.oxygenTank else {
    fatalError("Tanks missing for test")
}

var labLevel = labTank.level
var habLevel = habTank.level

let transferred = transferOxygen(from: &labLevel, to: &habLevel, amount: 30)
print("Transferred: \(transferred)")

labTank.level = labLevel
habTank.level = habLevel

print("Lab now: \(labTank.level), Hab now: \(habTank.level)")

// Фрагмент D
let D: Int
if let aigerim = roster["Aigerim"], let level = oxygenLevel(of: aigerim) {
    D = level
} else {
    D = 0
}
print("D = \(D)")


// 4.4
func evacuationOrder(_ names: String..., roster: [String: CrewMember]) -> [String] {
    var foundMembers: [CrewMember] = []

    for name in names {
        guard let member = roster[name] else {
            print("Unknown crew member: \(name)")
            continue
        }
        foundMembers.append(member)
    }

    let sorted = foundMembers.sorted { $0.priority < $1.priority }

    var result: [String] = []
    for member in sorted {
        result.append(member.name)
    }
    return result
}

// Тест
let order = evacuationOrder("Dana", "Ghost", "Aigerim", "Timur", roster: roster)
print(order)


// MARK: Level 5 · The Saboteur's Logbook
// The saboteur's code is below, commented out (it needs your
// oxygenLevel(of:) to compile). Comment on every problem, then
// write fixed versions and a test that proves the logic bug is gone.

/*
 func reportOxygen(for member: CrewMember) -> String {
     let tank = member.module!.oxygenTank!
     // Problem 1: member.module! crashes if the crew member has no module
     //   (member.module == nil). Nurlan has module == nil, so calling
     //   reportOxygen(for: nurlan) would crash the program.
 
     // Problem 2: .oxygenTank! crashes if the module has no tank
     //   (oxygenTank == nil). Dock has oxygenTank == nil, so calling
     //   reportOxygen(for: dana) would also crash the program.
     return "\(member.name): \(tank.level)%"
 }

 func firstCritical(in crew: [CrewMember]) -> String {
     var result: String?
     for member in crew {
         if oxygenLevel(of: member)! < 20 {
             // Problem 3: oxygenLevel(of: member)! crashes if the crew
             //   member has no oxygen data at all (oxygenLevel returns nil
             //   for Dana and Nurlan force unwrapping nil = crash).
             result = member.name
 
             // Problem 4 (logic bug, not about !): the loop doesn't stop at
             //   the first match it keeps going through the whole array
             //   and OVERWRITES result every time. The function is named
             //   firstCritical, but it actually returns the LAST match,
             //   not the first one. With the starter data the bug is
             //   invisible (only one person is critical), but with several
             //   critical crew members the result would be wrong.
         }
     }
     return result!
     // Problem 5: return result! crashes if nobody is critical at all
     //   (result stays nil the whole function, and force unwrapping it
     //   crashes).
 }
*/

func reportOxygen(for member: CrewMember) -> String {
    guard let tank = member.module?.oxygenTank else {
        return "\(member.name): no tank data"
    }
    return "\(member.name): \(tank.level)%"
}

func firstCritical(in crew: [CrewMember]) -> String? {
    for member in crew {
        if let level = oxygenLevel(of: member), level < 20 {
            return member.name
        }
    }
    return nil
}

// Tests:
if let nurlan = roster["Nurlan"] {
    print(reportOxygen(for: nurlan))
}
if let dana = roster["Dana"] {
    print(reportOxygen(for: dana))
}
if let timur = roster["Timur"] {
    print(reportOxygen(for: timur))
}

// Test:
print(firstCritical(in: crew) as Any)

// Test proving the logic bug is fixed:
let critModule1 = Module(name: "TestModA", oxygenTank: Tank(level: 15))
let critModule2 = Module(name: "TestModB", oxygenTank: Tank(level: 5))

let testCrew = [
    CrewMember(name: "First",  role: "Test", priority: 1, module: critModule1),
    CrewMember(name: "Second", role: "Test", priority: 2, module: critModule2)
]

print(firstCritical(in: testCrew) as Any)



// MARK: Finale · Launch Code

 let launchCode = "\(A)-\(B)-\(C)-\(D)"
 print("LAUNCH CODE: \(launchCode)")


// MARK: Bonus

func makeAlarm(threshold: Int) -> (Int) -> Bool {
    var alarmCount = 0

    return { level in
        let isCritical = level < threshold
        if isCritical {
            alarmCount += 1
            print("Alarm #\(alarmCount)")
        }
        return isCritical
    }
}

// Тесты
let alarm = makeAlarm(threshold: 20)
print(alarm(12))
print(alarm(40))
print(alarm(5))

let anotherAlarm = makeAlarm(threshold: 50)
print(anotherAlarm(30))
print(alarm(1))

// MARK: - ================= DEFENSE QUESTIONS =================
/*
 
  1. guard let vs if let beyond syntax:

  if let only unwraps inside its own { } block. guard let unwraps for the
  REST of the function, but requires the else branch to exit (return/continue/
  break). Example: in status(of:), guard let lets you handle the nil case
  first and exit, then use `level` normally below with no extra nesting.
  With if let, the whole rest of the logic would be nested one level deeper
  inside the if-block.


  2. Why can't you pass [Int] to stats(_ values: Int...)?

  Int... means "list values separated by commas at the call site"
  (stats(3, 8, 1)), not "accept an existing array". Swift doesn't
  automatically spread an array into a variadic parameter, even though
  inside the function values is already [Int].


  3. Why doesn't transferOxygen(from: &x, to: &x, amount: 5) compile?

  Both parameters are inout, so each needs exclusive write access. Passing
  the same variable twice would give two simultaneous exclusive references
  to one memory location, which Swift's exclusivity rule forbids. This
  prevents the function from reading/writing the same value in conflicting
  order and getting a broken result.


  4. Why doesn't oxygenLevel(of: dana) ?? "no data" compile?

  oxygenLevel(of:) returns Int?, but "no data" is a String. Both sides of ??
  must match types. Fixing it needs an Int fallback instead, e.g. ?? 0.


  5. Full type of chooseProtocol and how to read it:

  (Int) -> (Int) -> Int

  Read left to right: takes an Int (temperature), returns a function of
  type (Int) -> Int. So chooseProtocol gives you back another function,
  which you then call separately with another Int to apply it.


  Bonus. Where does the alarm counter live after makeAlarm returns?

  The returned closure captures alarmCount, so instead of being destroyed
  with the function's stack frame, it's moved to the heap and kept alive by
  ARC as long as the closure (e.g. `alarm`) still exists. Each call to
  makeAlarm creates its own separate captured counter.
 

*/

