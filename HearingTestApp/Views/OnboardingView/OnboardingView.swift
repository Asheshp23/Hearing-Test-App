//
//  OnboardingView.swift
//  HearingTestApp
//
//  Created by Ashesh Patel on 2025-05-18.
//
import SwiftUI

struct OnboardingView: View {
  @StateObject private var volumeManager = SystemVolumeManager()
  @State private var currentStep: OnboardingStep = .checkHeadphones
  @EnvironmentObject var router: Router
  
  // Target volume (50%)
  let targetVolume: Float = 0.5
 
  var isVolumeCorrect: Bool {
    let currentVolume = Int(volumeManager.currentVolume * 100)
    
    return currentVolume >= 45 && currentVolume <= 55
  }
  
  var body: some View {
    VStack(spacing: 30) {
      HStack {
        StepIndicator(text: "1. Connect", isActive: currentStep == .checkHeadphones || volumeManager.isHeadphonesConnected)
        Spacer()
        StepIndicator(text: "2. Set Volume", isActive: (volumeManager.isHeadphonesConnected && isVolumeCorrect))
        Spacer()
        StepIndicator(text: "3. Ready", isActive: currentStep == .ready)
      }
      .padding(.horizontal)
      .padding(.top)
      
      Spacer()
      
      switch currentStep {
      case .checkHeadphones:
        ConnectHeadphonesStepView(isHeadphonesConnected: volumeManager.isHeadphonesConnected)
      case .setVolume:
        SetVolumeStepView(
          currentVolume: volumeManager.currentVolume,
          targetVolume: targetVolume,
          isVolumeCorrect: isVolumeCorrect
        )
      case .ready:
        ReadyStepView()
      }
      
      Spacer()
      
      // Navigation Button / Logic
      if currentStep != .ready {
        Button(action: handleNextStep) {
          Text(buttonTextForCurrentStep())
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
            .padding()
            .background(isNextStepAllowed() ? Color.blue : Color.gray.opacity(0.5))
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .disabled(!isNextStepAllowed())
        .padding()
      } else {
        // Example: Button to proceed to main app
        Button("Start Hearing Test") {
          router.navigate(to: .test)
        }
        .fontWeight(.semibold)
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.green)
        .foregroundColor(.white)
        .cornerRadius(10)
        .padding()
      }
    }
    .navigationBarBackButtonHidden()
    .animation(.easeInOut, value: currentStep)
    .animation(.easeInOut, value: volumeManager.isHeadphonesConnected)
    .animation(.easeInOut, value: volumeManager.currentVolume)
    .onChange(of: volumeManager.isHeadphonesConnected) { _, connected in
      if currentStep == .checkHeadphones && connected {
        withAnimation {
          currentStep = .setVolume
        }
      } else if currentStep != .checkHeadphones && !connected {
        // If headphones get disconnected mid-flow, go back to checkHeadphones step
        withAnimation {
          currentStep = .checkHeadphones
        }
      }
    }
  }
  
  func handleNextStep() {
    withAnimation {
      switch currentStep {
      case .checkHeadphones:
        if volumeManager.isHeadphonesConnected {
          currentStep = .setVolume
        }
      case .setVolume:
        if isVolumeCorrect {
          currentStep = .ready
        }
      case .ready:
        // This case is handled by the "Start Hearing Test" button
        break
      }
    }
  }
  
  func isNextStepAllowed() -> Bool {
    switch currentStep {
    case .checkHeadphones:
      return volumeManager.isHeadphonesConnected
    case .setVolume:
      return isVolumeCorrect
    case .ready:
      return false
    }
  }
  
  func buttonTextForCurrentStep() -> String {
    switch currentStep {
    case .checkHeadphones:
      return volumeManager.isHeadphonesConnected ? "Continue" : "Waiting for Connection..."
    case .setVolume:
      return isVolumeCorrect ? "Continue" : "Adjust Volume to ~ 45% to 55%"
    case .ready:
      return "Start Test" // Should not be reached for this button
    }
  }
}

#Preview {
  OnboardingView()
}
