//
//  Router.swift
//  HearingTestApp
//
//  Created by Ashesh Patel on 2025-05-18.
//
import Foundation
import SwiftUI

enum AppRoute: Hashable {
  case onboarding, test, home
}

class Router: ObservableObject {
  @Published var path = NavigationPath()
  
  func navigate(to route: AppRoute) {
    path.append(route)
  }
  
  func navigateBack() {
    if !path.isEmpty {
      path.removeLast()
    }
  }
  
  func navigateToRoot() {
    path = NavigationPath()
  }
}
