import Foundation
import Numerics

enum TestError: Error {
  case testError(String)
}

func sum(_ x: Double, _ y: Double) -> Double {
  return x + y
}
