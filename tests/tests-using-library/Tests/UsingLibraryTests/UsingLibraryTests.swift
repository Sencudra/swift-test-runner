import Foundation
import Testing
import Numerics

@testable import UsingLibrary

@Test("test Add")
func testAdd() {
  #expect(sum((1/3), (1/3)).isApproximatelyEqual(to: 2/3), "1/3+1/3 should equal 2/3")
}
