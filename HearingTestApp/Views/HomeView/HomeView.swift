//
//  HomeView.swift
//  HearingTestApp
//
//  Created by Ashesh Patel on 2025-05-18.
//
import SwiftUI

struct HomeView: View {
  @EnvironmentObject var router: Router

  var body: some View {
    VStack(spacing: 20) {
      Spacer()
      
      Image(systemName: "waveform.path.ecg")
        .font(.system(size: 60))
        .foregroundColor(.accentColor)
        .padding(.bottom, 20)
      
      Text("Welcome to Hearing App")
        .font(.largeTitle)
        .fontWeight(.bold)
        .multilineTextAlignment(.center)
      
      Text("Your journey to better hearing starts here.")
        .font(.headline)
        .foregroundColor(.secondary)
        .multilineTextAlignment(.center)
        .padding(.bottom, 30)
      
      VStack(spacing: 15) {
        Button {
          router.navigate(to: .onboarding)
        } label: {
          Label("Start", systemImage: "hand.wave.fill")
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
      }
      .padding(.horizontal)
      
      Spacer()
    }
    .padding()
  }
}
