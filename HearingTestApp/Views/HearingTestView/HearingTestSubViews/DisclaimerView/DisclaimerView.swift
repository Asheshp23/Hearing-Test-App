//
//  DisclaimerView.swift
//  HearingTestApp
//
//  Created by Ashesh Patel on 2025-05-14.
//
import SwiftUI

struct DisclaimerView: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 5) {
      Text("Disclaimer:")
        .font(.caption.bold())
      Text("This app is NOT a medical device and CANNOT replace a professional hearing test. Results are for screening purposes only. Use in a quiet environment with consistent headphone volume (e.g., 45% to 55% ). Results depend heavily on headphone quality.")
        .font(.caption)
    }
    .padding()
    .background(Color.yellow.opacity(0.2))
    .cornerRadius(8)
    .padding(.horizontal)
  }
}

#Preview {
  DisclaimerView()
}
