//
//  SetVolumeStepView.swift
//  HearingTestApp
//
//  Created by Ashesh Patel on 2025-05-18.
//
import SwiftUI

struct SetVolumeStepView: View {
  let currentVolume: Float
  let targetVolume: Float
  let isVolumeCorrect: Bool
  
  var body: some View {
    VStack(spacing: 20) {
      Image(systemName: "speaker.wave.2.circle" ) // Could be headphones with volume slider
        .font(.system(size: 80))
        .foregroundColor(isVolumeCorrect ? .green : .blue)
      
      Text("Set Volume to ~ 45% to 55%")
        .font(.title2)
        .fontWeight(.bold)
      
      Text("Use your device's volume buttons to adjust the output volume. Aim for the middle of the volume range.")
        .font(.body)
        .foregroundColor(.secondary)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 40)
      
      // Volume Indicator
      VStack {
        HStack {
          Image(systemName: "speaker.fill")
          ProgressView(value: currentVolume, total: 1.0)
            .frame(height: 10)
            .tint(isVolumeCorrect ? .green : .blue)
          Image(systemName: "speaker.wave.3.fill")
        }
        Text("Current Volume: \(Int(currentVolume * 100))%")
          .font(.caption)
          .foregroundColor(isVolumeCorrect ? .green : .primary)
      }
      .padding()
      .background(Color.gray.opacity(0.1))
      .cornerRadius(10)
      .padding(.horizontal, 40)
      
      if !isVolumeCorrect {
        Text(currentVolume < targetVolume - 0.05 ? "A bit louder, please." : "A bit softer, please.")
          .font(.callout)
          .foregroundColor(.orange)
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}
