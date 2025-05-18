//
//  ConnectHeadphonesStepView.swift
//  HearingTestApp
//
//  Created by Ashesh Patel on 2025-05-18.
//
import SwiftUI

struct ConnectHeadphonesStepView: View {
  let isHeadphonesConnected: Bool
  
  var body: some View {
    VStack(spacing: 20) {
      Image(systemName: isHeadphonesConnected ? "headphones.circle.fill" : "headphones.circle")
        .font(.system(size: 80))
        .foregroundColor(isHeadphonesConnected ? .green : .orange)
      
      Text(isHeadphonesConnected ? "Headphones Connected!" : "Connect Your Headphones")
        .font(.title2)
        .fontWeight(.bold)
      
      Text(isHeadphonesConnected ? "Great! Let's proceed to set the volume." : "Please plug in your wired headphones or connect a Bluetooth audio device to continue.")
        .font(.body)
        .foregroundColor(.secondary)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 40)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}
