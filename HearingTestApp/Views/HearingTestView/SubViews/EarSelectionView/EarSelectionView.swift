//
//  EarSelectionView.swift
//  HearingTestApp
//
//  Created by Ashesh Patel on 2025-05-14.
//
import SwiftUI

struct EarSelectionView: View {
  @ObservedObject var viewModel: HearingTestViewModel
  
  var body: some View {
    VStack {
      Text("Select Ear to Test:")
        .font(.title2)
      HStack(spacing: 20) {
        if viewModel.results[.left]?.isEmpty ?? true {
          Button("Left Ear") {
            viewModel.selectEar(.left)
          }
          .padding()
          .buttonStyle(.bordered)
          .disabled(viewModel.testPhase == .testing)
        }
        
        if viewModel.results[.right]?.isEmpty ?? true {
          Button("Right Ear") {
            viewModel.selectEar(.right)
          }
          .padding()
          .buttonStyle(.bordered)
          .disabled(viewModel.testPhase == .testing)
        }
      }
    }
  }
}
