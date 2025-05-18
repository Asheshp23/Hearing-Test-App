//
//  ContentView.swift
//  HearingTestApp
//
//  Created by Ashesh Patel on 2025-05-13.
//
import SwiftUI

struct ContentView: View {
  @StateObject private var router = Router()
  
  var body: some View {
    NavigationStack(path: $router.path) {
      HomeView()
        .navigationDestination(for: AppRoute.self) { route in
          switch route {
          case .onboarding:
            OnboardingView()
          case .test:
            HearingTestView()
          case .home:
            HomeView()
          }
        }
    }
    .environmentObject(router)
  }
}
