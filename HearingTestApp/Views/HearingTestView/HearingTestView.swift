//
//  HearingTestView.swift
//  HearingTestApp
//
//  Created by Ashesh Patel on 2025-05-14.
//
import SwiftUI

struct HearingTestView: View {
  @StateObject private var viewModel = HearingTestViewModel()
  @Environment(\.scenePhase) var scenePhase
  @StateObject private var volumeManager = SystemVolumeManager()
  @EnvironmentObject var router: Router
  
  var body: some View {
    ScrollView {
      VStack(spacing: 20) {
        Text("Hearing Screening Test")
          .font(.largeTitle)
          .padding(.top)
        
        Text(viewModel.instructionText)
          .font(.headline)
          .multilineTextAlignment(.center)
          .padding(.horizontal)
          .frame(minHeight: 60) // Ensure some space
        
        if viewModel.testPhase == .idle || (viewModel.testPhase == .earFinished && !viewModel.allEarsFullyTested()) {
          EarSelectionView(viewModel: viewModel)
        }
        
        if viewModel.testPhase == .testing {
          TestingControlsView(viewModel: viewModel)
        }
        
        if viewModel.testPhase == .earFinished || viewModel.testPhase == .finished {
          ResultsSummaryView(viewModel: viewModel)
            .padding(.top)
          
          AudiogramView(results: viewModel.results)
            .frame(height: 350) // Adjust height as needed
            .padding()
            .overlay(
              RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray, lineWidth: 1)
            )
        }
        
        if viewModel.testPhase == .finished {
          Button("Restart Test") {
            viewModel.restartTest()
          }
          .padding()
          .buttonStyle(.borderedProminent)
        }
        
        Spacer(minLength: 20)
        
        DisclaimerView()
          .padding(.bottom)
        
      }
      .navigationTitle("Hearing Test")
      .navigationBarHidden(true)
    }
    .onAppear(perform: viewModel.onAppear)
    .onDisappear(perform: viewModel.onDisappear)
    .onChange(of: volumeManager.isHeadphonesConnected, { oldValue, newValue in
      if !newValue {
        router.navigateBack()
      }
    })
    .alert(isPresented: $viewModel.showAlert) {
      Alert(title: Text("Information"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
    }
  }
}

#Preview {
  HearingTestView()
}
