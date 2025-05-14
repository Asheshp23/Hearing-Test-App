//
//  AudiogramView.swift
//  HearingTestApp
//
//  Created by Ashesh Patel on 2025-05-13.
//
import SwiftUI
import Charts

struct AudiogramView: View {
  let results: [Ear: [HearingTestDataPoint]]
  
  private let yMinDb: Double = -10
  private let yMaxDb: Double = 120
  private let xMinFreq: Double = 125
  private let xMaxFreq: Double = 8000
  
  private let audiogramFrequencyTicks: [Double] = [125, 250, 500, 750, 1000, 1500, 2000, 3000, 4000, 6000, 8000]
  private let dbLevelTicks: [Double] = stride(from: -10, through: 120, by: 10).map { $0 }
  private let symbolSize: CGFloat = 8
  
  // Environment value to check size class (for adaptive label rotation)
  @Environment(\.horizontalSizeClass) var horizontalSizeClass
  
  var body: some View {
    VStack(alignment: .leading, spacing: 5) {
      Text("(Frequency in Hz)")
        .font(.caption)
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.bottom, -10)
      
      HStack {
        Chart {
          // ... (normalHearingAreaMark and earSeriesMarks calls remain the same)
          normalHearingAreaMark()
          if let rightEarResults = results[.right], !rightEarResults.isEmpty {
            earSeriesMarks(for: .right, results: rightEarResults)
          }
          if let leftEarResults = results[.left], !leftEarResults.isEmpty {
            earSeriesMarks(for: .left, results: leftEarResults)
          }
        }
        .chartYScale(domain: yMinDb...yMaxDb)
        .chartYAxis {
          AxisMarks(values: dbLevelTicks) { value in
            AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: (value.as(Double.self) == 0 || value.as(Double.self) == 20) ? [] : [2,3]))
              .foregroundStyle(Color.gray.opacity(0.5))
            AxisTick()
            AxisValueLabel() {
              if let dbValue = value.as(Double.self) { Text("\(Int(dbValue))") }
            }
          }
        }
        .chartYAxisLabel("Hearing Level (dBHL)", alignment: .center)
        
        // --- X-Axis Configuration (Frequency) ---
        .chartXScale(domain: xMinFreq...xMaxFreq, type: .log)
        .chartXAxis {
          AxisMarks(values: audiogramFrequencyTicks) { value in
            AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: ([250,500,1000,2000,4000,8000].contains(value.as(Double.self) ?? 0)) ? [] : [2,3] ))
              .foregroundStyle(Color.gray.opacity(0.5))
            AxisTick()
            AxisValueLabel() {
              if let freqValue = value.as(Double.self) {
                Text("\(Int(freqValue))")
                  .font(.caption2) // Reduce font size
                // Rotate labels slightly to prevent overlap
                // Adjust angle and anchor as needed
                // Only rotate on compact widths, or always if preferred
                  .rotationEffect(Angle(degrees: horizontalSizeClass == .compact ? -30 : 0),
                                  anchor: horizontalSizeClass == .compact ? .trailing : .center)
                // Add padding if rotation makes it too close to the axis line
                  .padding(.top, horizontalSizeClass == .compact ? 5 : 0)
                
              }
            }
            // Optional: Control label skipping/culling further if needed
            // .label(collisionResolution: .greedy(maxCount: audiogramFrequencyTicks.count))
            // .label(spacing: 5) // Minimum spacing between labels
          }
        }
        .chartLegend(.hidden)
        .padding(.trailing, 20) // For Y-axis label if it were on right
        // Add bottom padding to make space for rotated X-axis labels
        .padding(.bottom, horizontalSizeClass == .compact ? 20 : 5)
      }
    }
    .background(Color(uiColor: .systemBackground))
    .frame(minHeight: 300)
    .padding()
  }
  
  // ... (helper functions: normalHearingAreaMark, earSeriesMarks)
  @ChartContentBuilder
  private func normalHearingAreaMark() -> some ChartContent {
    RectangleMark(
      xStart: .value("Min Freq", xMinFreq),
      xEnd: .value("Max Freq", xMaxFreq),
      yStart: .value("Normal Min dB", 0),
      yEnd: .value("Normal Max dB", 20)
    )
    .foregroundStyle(Color.gray.opacity(0.2))
    .accessibilityLabel("Normal hearing range")
  }
  
  @ChartContentBuilder
  private func earSeriesMarks(for ear: Ear, results: [HearingTestDataPoint]) -> some ChartContent {
    let sortedResults = results.sorted { $0.frequency < $1.frequency }
    let earColor = (ear == .right) ? Color.red : Color.blue
    
    ForEach(sortedResults) { dataPoint in
      LineMark(
        x: .value("Frequency", dataPoint.frequency),
        y: .value("Hearing Level (dB)", dataPoint.intensity)
      )
    }
    .foregroundStyle(earColor)
    .interpolationMethod(.monotone)
    
    ForEach(sortedResults) { dataPoint in
      PointMark(
        x: .value("Frequency", dataPoint.frequency),
        y: .value("Hearing Level (dB)", dataPoint.intensity)
      )
      .foregroundStyle(earColor)
      .symbol {
        if ear == .right {
          Circle().strokeBorder(lineWidth: 1.5).frame(width: symbolSize, height: symbolSize)
        } else {
          CrossSymbol().stroke(style: StrokeStyle(lineWidth: 1.5)).frame(width: symbolSize, height: symbolSize)
        }
      }
    }
  }
}

// ... (CrossSymbol and Preview remain the same)
// Custom Shape for 'X' symbol (remains the same)
struct CrossSymbol: Shape {
  func path(in rect: CGRect) -> Path {
    var path = Path()
    path.move(to: CGPoint(x: rect.minX, y: rect.minY))
    path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
    path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
    path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
    return path
  }
}

// MARK: - Preview (remains the same)
struct AudiogramView_Previews: PreviewProvider {
  static var sampleResults: [Ear: [HearingTestDataPoint]] {
    let rightEarData: [HearingTestDataPoint] = [
      .init(frequency: 250, intensity: 10), .init(frequency: 500, intensity: 10),
      .init(frequency: 1000, intensity: 20), .init(frequency: 2000, intensity: 25),
      .init(frequency: 3000, intensity: 35), .init(frequency: 4000, intensity: 40),
      .init(frequency: 6000, intensity: 60), .init(frequency: 8000, intensity: 25)
    ]
    let leftEarData: [HearingTestDataPoint] = [
      .init(frequency: 250, intensity: 15), .init(frequency: 500, intensity: 15),
      .init(frequency: 1000, intensity: 25), .init(frequency: 2000, intensity: 45),
      .init(frequency: 4000, intensity: 55), .init(frequency: 8000, intensity: 50)
    ]
    return [.right: rightEarData, .left: leftEarData]
  }
  
  static var previews: some View {
    VStack {
      Text("Audiogram (SwiftUI Charts)")
        .font(.title2)
      AudiogramView(results: sampleResults)
        .frame(height: 400)
        .padding()
      Spacer()
    }
  }
}
