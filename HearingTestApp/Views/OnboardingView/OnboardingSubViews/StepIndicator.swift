//
//  StepIndicator.swift
//  HearingTestApp
//
//  Created by Ashesh Patel on 2025-05-18.
//
import SwiftUI

struct StepIndicator: View {
  let text: String
  let isActive: Bool
  
  var body: some View {
    Text(text)
      .font(.caption)
      .padding(8)
      .background(isActive ? Color.blue.opacity(0.7) : Color.gray.opacity(0.3))
      .foregroundColor(isActive ? .white : .gray)
      .cornerRadius(8)
  }
}
