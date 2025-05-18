//
//  ReadyStepView.swift
//  HearingTestApp
//
//  Created by Ashesh Patel on 2025-05-18.
//
import SwiftUI

struct ReadyStepView: View {
  var body: some View {
    VStack(spacing: 20) {
      Image(systemName: "checkmark.circle.fill")
        .font(.system(size: 80))
        .foregroundColor(.green)
      
      Text("All Set!")
        .font(.title2)
        .fontWeight(.bold)
      
      Text("You're ready to begin the hearing test. Ensure you are in a quiet environment.")
        .font(.body)
        .foregroundColor(.secondary)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 40)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}
