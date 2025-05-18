//
//  HearingTestDataPoint.swift
//  HearingTestApp
//
//  Created by Ashesh Patel on 2025-05-13.
//
import Foundation

// Represents a single data point on the audiogram
struct HearingTestDataPoint: Identifiable, Hashable {
  let id = UUID()
  var frequency: Double // Hz
  var intensity: Double // dB (relative)
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(frequency)
    hasher.combine(intensity)
  }
  
  static func == (lhs: HearingTestDataPoint, rhs: HearingTestDataPoint) -> Bool {
    lhs.frequency == rhs.frequency && lhs.intensity == rhs.intensity
  }
}

enum Ear: String, CaseIterable, Identifiable {
  case left = "Left"
  case right = "Right"
  
  var id: String { self.rawValue }
  var symbol: String {
    switch self {
    case .left: return "X"
    case .right: return "O"
    }
  }
}

enum TestPhase {
  case idle // Initial state, ready to select ear
  case selectingEar
  case testing // Actively testing a frequency
  case earFinished // One ear done, ready for next or to view results
  case finished // Both ears tested
}
