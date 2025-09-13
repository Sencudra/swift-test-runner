import Foundation
import Numerics
import Testing

@testable import TestEnvironment

let RUNALL = Bool(ProcessInfo.processInfo.environment["RUNALL", default: "false"]) ?? false

@Test("rotate", .enabled(if: RUNALL))
func testAdd() {
  #expect(sum(2, 3) == 5, "2+3 should equal 5")
}
