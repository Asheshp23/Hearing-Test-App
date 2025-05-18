//
//  ResultsSummaryView.swift
//  HearingTestApp
//
//  Created by Ashesh Patel on 2025-05-14.
//
import SwiftUI

struct ResultsSummaryView: View {
  @ObservedObject var viewModel: HearingTestViewModel
  
  var body: some View {
    VStack {
      Text("Results")
        .font(.title2)
        .padding(.bottom, 5)
      
      // Simplified Textual Audiogram
      HStack(alignment: .top) {
        Text("Freq (Hz)").bold().frame(width: 80, alignment: .leading)
        Text("Left (dB)").bold().frame(width: 70, alignment: .center)
        Text("Right (dB)").bold().frame(width: 70, alignment: .center)
      }
      .padding(.bottom, 2)
      
      ForEach(viewModel.testFrequencies, id: \.self) { freq in
        HStack {
          Text("\(Int(freq))").frame(width: 80, alignment: .leading)
          Text(resultString(for: .left, frequency: freq))
            .frame(width: 70, alignment: .center)
          Text(resultString(for: .right, frequency: freq))
            .frame(width: 70, alignment: .center)
        }
        Divider()
      }
    }
    .padding()
    .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
    .padding(.horizontal)
  }
  
  func resultString(for ear: Ear, frequency: Double) -> String {
    if let point = viewModel.results[ear]?.first(where: { $0.frequency == frequency }) {
      if point.intensity > viewModel.maxIntensity { // Check for our "not heard" marker
        return ">\(Int(viewModel.maxIntensity))"
      }
      return "\(Int(point.intensity))"
    }
    return "-" // Not tested or no result
  }
}
