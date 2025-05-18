import AVFoundation
import MediaPlayer
import Combine
import UIKit

@MainActor
class SystemVolumeManager: ObservableObject {
  @Published var currentVolume: Float = 0.0
  @Published var isHeadphonesConnected: Bool = false
  
  private var audioSession = AVAudioSession.sharedInstance()
  private var volumeObservation: NSKeyValueObservation?
  private var systemVolumeSlider: UISlider?
  
  private var isSettingProgrammatically = false
  private var cancellables = Set<AnyCancellable>()
  
  init() {
    do {
      try audioSession.setCategory(.playback, mode: .default, options: [])
      try audioSession.setActive(true)
    } catch {
      print("Error setting up audio session: \(error.localizedDescription)")
    }
    currentVolume = audioSession.outputVolume
    print("LOG: Initial system volume: \(currentVolume)")
    updateHeadphoneConnectionStatus() // Initial check
    
    volumeObservation = audioSession.observe(\.outputVolume, options: [.new, .initial]) { [weak self] (_, change) in
      guard let self = self, let newVolume = change.newValue else { return }
      Task {
        await MainActor.run {
          if !self.isSettingProgrammatically || abs(newVolume - self.currentVolume) > 0.01 {
            print("LOG: System volume changed (observed): \(newVolume)")
            self.currentVolume = newVolume
          }
        }
      }
    }
    
    $currentVolume
      .debounce(for: .milliseconds(50), scheduler: RunLoop.main)
      .sink { [weak self] newVolumeFromUI in
        guard let self = self else { return }
        if abs(newVolumeFromUI - self.audioSession.outputVolume) > 0.001 && self.systemVolumeSlider != nil {
          print("LOG: UI wants to set volume to: \(newVolumeFromUI)")
          self.setSystemVolume(to: newVolumeFromUI)
        }
      }
      .store(in: &cancellables)
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleRouteChange),
      name: AVAudioSession.routeChangeNotification,
      object: nil // Observe for all audio sessions (system-wide)
    )
  }
  
  @objc private func handleRouteChange(notification: Notification) {
    Task { @MainActor in
      print("LOG: Audio route changed notification received.")
      self.updateHeadphoneConnectionStatus()
    }
  }
  
  private func updateHeadphoneConnectionStatus() {
    let currentRoute = audioSession.currentRoute
    var headphonesConnected = false
    for output in currentRoute.outputs {
      switch output.portType {
      case .headphones, .bluetoothA2DP, .bluetoothLE: // Common headphone types
        headphonesConnected = true
        print("LOG: Headphones detected via port: \(output.portName) (\(output.portType.rawValue))")
        break
      default:
        break
      }
    }
    
    if self.isHeadphonesConnected != headphonesConnected {
      self.isHeadphonesConnected = headphonesConnected
      print("LOG: Headphone connection status updated to: \(self.isHeadphonesConnected)")
    }
  }
  
  func registerVolumeSlider(_ slider: UISlider?) {
    self.systemVolumeSlider = slider
    if slider == nil { print("LOG WARNING: SystemVolumeManager received nil for systemVolumeSlider.") }
    else { print("LOG: SystemVolumeManager registered MPVolumeView slider.") }
  }
  
  func setSystemVolume(to volume: Float) {
    guard !isSettingProgrammatically else { return }
    guard let slider = systemVolumeSlider else {
      print("LOG Error: System volume slider not available.")
      return
    }
    isSettingProgrammatically = true
    slider.setValue(volume, animated: false)
    slider.sendActions(for: .valueChanged)
    print("LOG: Programmatically setting system volume to: \(volume)")
    Task {
      do { try await Task.sleep(for: .milliseconds(150)) } catch {}
      self.isSettingProgrammatically = false
    }
  }
  
  deinit {
    volumeObservation?.invalidate()
    NotificationCenter.default.removeObserver(self, name: AVAudioSession.routeChangeNotification, object: nil)
    
    print("LOG: SystemVolumeManager deinitialized.")
  }
}
