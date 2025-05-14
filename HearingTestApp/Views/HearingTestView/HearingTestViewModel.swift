//
//  HearingTestViewModel.swift
//  HearingTestApp
//
//  Created by Ashesh Patel on 2025-05-13.
//
import Foundation
import Combine

@MainActor // Ensures UI updates are on the main thread
class HearingTestViewModel: ObservableObject {
  @Published var currentEar: Ear? = nil
  @Published var testPhase: TestPhase = .idle
  @Published var currentFrequency: Double = 0
  @Published var currentIntensity: Double = 0 // dB value for UI
  @Published var results: [Ear: [HearingTestDataPoint]] = [.left: [], .right: []]
  @Published var instructionText: String = "Select an ear to begin the test."
  @Published var showAlert: Bool = false
  @Published var alertMessage: String = ""
  
  private var toneGenerator = ToneGenerator()
  
  let testFrequencies: [Double] = [250, 500, 1000, 2000, 4000, 8000] // Standard audiogram frequencies
  private var currentFrequencyIndex: Int = 0
  private let initialIntensity: Double = 40 // Start at a likely audible level (e.g., 40dB)
  let maxIntensity: Double = 100 // Quietest sound we'll test (e.g., 100dB)
  private let minIntensity: Double = 0   // Loudest sound we'll test (e.g., 0dB)
  private let intensityStepDown: Double = 10
  private let intensityStepUp: Double = 5
  
  // Simplified Hughson-Westlake like procedure state
  private var lastHeardIntensity: Double?
  private var reversals: Int = 0 // Count of up/down direction changes
  private var ascendingRunHeardCount: Int = 0
  
  init() {
    // Ensure initial state is clear
    resetTestForNewEar()
  }
  
  func selectEar(_ ear: Ear) {
    guard testPhase == .idle || testPhase == .earFinished else { return }
    
    if results[ear]?.isEmpty == false && ear == .left && currentEar == .right {
      // If left ear was tested, and now right is selected, but left results exist.
      // This logic might need refinement depending on desired flow.
      // For now, assume we always test one then the other or restart.
    }
    
    currentEar = ear
    results[ear] = [] // Clear previous results for this ear if re-testing
    resetTestForNewEar()
    startTestingEar()
  }
  
  private func resetTestForNewEar() {
    currentFrequencyIndex = 0
    currentIntensity = initialIntensity
    lastHeardIntensity = nil
    reversals = 0
    ascendingRunHeardCount = 0
    if let ear = currentEar {
      instructionText = "Testing \(ear.rawValue) ear. Listen carefully."
    } else {
      instructionText = "Select an ear to begin."
    }
  }
  
  private func startTestingEar() {
    guard currentEar != nil else {
      instructionText = "Error: No ear selected."
      testPhase = .idle
      return
    }
    guard currentFrequencyIndex < testFrequencies.count else {
      finishEarTest()
      return
    }
    
    testPhase = .testing
    currentFrequency = testFrequencies[currentFrequencyIndex]
    currentIntensity = initialIntensity // Reset intensity for new frequency
    lastHeardIntensity = nil
    reversals = 0
    ascendingRunHeardCount = 0
    updateInstructionText()
    playCurrentTone()
  }
  
  func playCurrentTone() {
    guard testPhase == .testing, let ear = currentEar else {
      print("ViewModel: playCurrentTone - Cannot play, testPhase: \(testPhase), currentEar: \(String(describing: currentEar))")
      return
    }
    
    var panPosition: Float = 0.0 // Default to center if something is wrong
    switch ear {
    case .left:
      panPosition = -1.0 // Full left
    case .right:
      panPosition = 1.0  // Full right
    }
    
    print("ViewModel: Playing tone for \(ear.rawValue) ear. Pan: \(panPosition), Freq: \(currentFrequency), dB: \(currentIntensity)")
    toneGenerator.playTone(frequency: currentFrequency,
                           intensityDb: currentIntensity,
                           panPosition: panPosition) // Pass the pan position
    updateInstructionText()
  }
  
  
  func stopCurrentTone() {
    toneGenerator.stopTone()
  }
  
  // Simplified Threshold Logic: (Down 10, Up 5)
  // A common procedure:
  // 1. Start at audible level.
  // 2. Decrease by 10 dB until not heard.
  // 3. Increase by 5 dB until heard. This is a potential threshold.
  // 4. Repeat step 2 & 3. True threshold is often defined as lowest level heard 2 out of 3 times on ascending runs.
  // For simplicity, we'll find the first ascending "heard".
  
  func userHeardTone() {
    guard testPhase == .testing else { return }
    toneGenerator.stopTone() // Stop tone on response
    
    lastHeardIntensity = currentIntensity
    ascendingRunHeardCount += 1 // Increment if heard on an ascending presentation
    
    // Descend
    currentIntensity -= intensityStepDown
    if currentIntensity < minIntensity {
      currentIntensity = minIntensity // Or record threshold if it's the lowest
      recordThresholdAndProceed() // If they hear at 0dB, that's the threshold
      return
    }
    
    reversals += 1 // Assuming this is a change in direction from a previous "not heard"
    playCurrentToneAfterDelay()
  }
  
  func userDidNotHearTone() {
    guard testPhase == .testing else { return }
    toneGenerator.stopTone() // Stop tone on response
    
    // Ascend
    currentIntensity += intensityStepUp
    ascendingRunHeardCount = 0 // Reset count if not heard
    
    if currentIntensity > maxIntensity {
      // If they can't hear even at maxIntensity, record as "> maxIntensity" or just maxIntensity
      // For this app, we'll just say they didn't hear it if it goes beyond max
      if let lastHeard = lastHeardIntensity {
        results[currentEar!]?.append(HearingTestDataPoint(frequency: currentFrequency, intensity: lastHeard))
      } else {
        // If nothing was heard at all for this frequency even after ascending up to maxIntensity
        // Mark as > maxIntensity or a special value. For now, use maxIntensity + 1 as a marker.
        results[currentEar!]?.append(HearingTestDataPoint(frequency: currentFrequency, intensity: maxIntensity + 1))
      }
      moveToNextFrequency()
      return
    }
    
    // If we were descending and now are ascending, that's a reversal
    if lastHeardIntensity != nil { // Implies we were going down
      reversals += 1
    }
    
    // If we have had enough reversals (e.g., 2 or 3) and the last response was "heard",
    // and this "not heard" is after a "heard", then the lastHeardIntensity is the threshold.
    // Simplified: If lastHeardIntensity is set (meaning they heard something)
    // and now they don't hear, the lastHeardIntensity is the threshold.
    if let threshold = lastHeardIntensity, reversals >= 1 { // Simplified condition
      recordThresholdAndProceed(thresholdValue: threshold)
    } else {
      playCurrentToneAfterDelay()
    }
  }
  
  private func recordThresholdAndProceed(thresholdValue: Double? = nil) {
    let finalThreshold = thresholdValue ?? lastHeardIntensity ?? currentIntensity
    // Ensure threshold is within bounds
    let boundedThreshold = max(minIntensity, min(maxIntensity, finalThreshold))
    
    if var earResults = results[currentEar!] {
      earResults.append(HearingTestDataPoint(frequency: currentFrequency, intensity: boundedThreshold))
      results[currentEar!] = earResults
      print("Recorded for \(currentEar!.rawValue) @ \(currentFrequency) Hz: \(boundedThreshold) dB")
    }
    moveToNextFrequency()
  }
  
  
  private func moveToNextFrequency() {
    currentFrequencyIndex += 1
    if currentFrequencyIndex < testFrequencies.count {
      startTestingEar() // This will reset intensity for the new frequency
    } else {
      finishEarTest()
    }
  }
  
  private func finishEarTest() {
    toneGenerator.stopTone()
    if let ear = currentEar {
      instructionText = "Finished testing \(ear.rawValue) ear."
      testPhase = .earFinished
      
      // Check if both ears are done
      let allEarsTested = Ear.allCases.allSatisfy { results[$0]?.count == testFrequencies.count }
      if allEarsTested {
        testPhase = .finished
        instructionText = "Hearing test complete! View results."
      } else if ear == .left && results[.right]?.isEmpty ?? true {
        instructionText += " Tap 'Test Right Ear' to continue."
      } else if ear == .right && results[.left]?.isEmpty ?? true {
        instructionText += " Tap 'Test Left Ear' to continue."
      }
    }
  }
  
  func restartTest() {
    testPhase = .idle
    currentEar = nil
    results = [.left: [], .right: []]
    resetTestForNewEar()
    instructionText = "Select an ear to begin the test."
  }
  
  private func updateInstructionText() {
    if testPhase == .testing {
      instructionText = "Testing \(currentEar?.rawValue ?? "") Ear: \(Int(currentFrequency)) Hz at \(Int(currentIntensity)) dB"
    }
  }
  
  private func playCurrentToneAfterDelay() {
    // Add a small delay before playing next tone to avoid overwhelming user
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) { [weak self] in
      self?.playCurrentTone()
    }
  }
  
  func onAppear() {
    // Called when ContentView appears
  }
  
  func onDisappear() {
    toneGenerator.stopTone()// Important to stop audio when view is not active
  }
  
  func appWillResignActive() {
    toneGenerator.stopTone()
  }
  
  func allEarsFullyTested() -> Bool {
    return (self.results[.left]?.count ?? 0) == self.testFrequencies.count &&
    (self.results[.right]?.count ?? 0) == self.testFrequencies.count
  }
}
