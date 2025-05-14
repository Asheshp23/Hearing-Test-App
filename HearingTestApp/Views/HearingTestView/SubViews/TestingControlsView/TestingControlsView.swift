//
//  TestingControlsView.swift
//  HearingTestApp
//
//  Created by Ashesh Patel on 2025-05-14.
//
import SwiftUI

struct TestingControlsView: View {
  @ObservedObject var viewModel: HearingTestViewModel
  
  var body: some View {
    VStack(spacing: 25) {
      Text("Frequency: \(Int(viewModel.currentFrequency)) Hz")
      Text("Intensity: \(Int(viewModel.currentIntensity)) dB")
      
      Button {
        viewModel.playCurrentTone()
      } label: {
        Label("Play Tone", systemImage: "play.circle.fill")
          .font(.title2)
      }
      .padding()
      .buttonStyle(.bordered)
      
      
      HStack(spacing: 30) {
        Button {
          viewModel.userHeardTone()
        } label: {
          Label("I Heard It", systemImage: "ear.and.waveform")
            .padding()
        }
        .buttonStyle(.borderedProminent)
        .tint(.green)
        
        Button {
          viewModel.userDidNotHearTone()
        } label: {
          Label("Didn't Hear", systemImage: "ear.badge.xmark")
            .padding()
        }
        .buttonStyle(.borderedProminent)
        .tint(.red)
      }
    }
    .padding()
  }
}
