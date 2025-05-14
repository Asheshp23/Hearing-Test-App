//
//  ToneGenerator.swift
//  HearingTestApp
//
//  Created by Ashesh Patel on 2025-05-13.
//
import AVFoundation
import Combine

class ToneGenerator: ObservableObject {
  private var audioEngine: AVAudioEngine!
  private var playerNode: AVAudioPlayerNode!
  // This is the format for BOTH the playerNode's output connection AND the buffers we schedule.
  private var audioProcessingFormat: AVAudioFormat!
  private var isEngineSetupSuccessfully = false
  
  // ... (amplitude function remains the same)
  private func amplitude(forDb db: Double) -> Float {
    let maxAppAmplitude: Float = 0.5
    let minAppAmplitude: Float = 0.0001
    let clampedDb = max(0, min(110, db))
    let proportion = 1.0 - (Float(clampedDb) / 110.0)
    let calculatedAmplitude = minAppAmplitude + (maxAppAmplitude - minAppAmplitude) * pow(proportion, 2)
    return max(minAppAmplitude, min(maxAppAmplitude, calculatedAmplitude))
  }
  
  init() {
    print("ToneGenerator: Initialized.")
  }
  
  private func configureAudioSession() -> Bool {
    do {
      let session = AVAudioSession.sharedInstance()
      try session.setCategory(.playback, mode: .default, options: [.mixWithOthers, .duckOthers])
      try session.setActive(true)
      print("ToneGenerator: AVAudioSession configured and activated.")
      return true
    } catch {
      print("ToneGenerator: Failed to configure or activate AVAudioSession: \(error.localizedDescription)")
      return false
    }
  }
  
  private func setupAudioEngineIfNeeded() -> Bool {
    if isEngineSetupSuccessfully && audioEngine.isRunning {
      return true
    }
    
    print("ToneGenerator: Setting up audio engine...")
    if !configureAudioSession() {
      isEngineSetupSuccessfully = false
      return false
    }
    
    audioEngine = AVAudioEngine()
    playerNode = AVAudioPlayerNode()
    
    let outputNode = audioEngine.outputNode
    let hardwareSampleRate = outputNode.outputFormat(forBus: 0).sampleRate
    
    guard hardwareSampleRate > 0 else {
      print("ToneGenerator: Could not get a valid hardware sample rate.")
      isEngineSetupSuccessfully = false
      return false
    }
    
    // Use STEREO format for the playerNode's processing and its connection.
    // Pan works on a stereo signal.
    audioProcessingFormat = AVAudioFormat(standardFormatWithSampleRate: hardwareSampleRate, channels: 2) // STEREO
    
    guard audioProcessingFormat != nil else {
      print("ToneGenerator: Failed to create audio processing format.")
      isEngineSetupSuccessfully = false
      return false
    }
    
    audioEngine.attach(playerNode)
    // Connect playerNode to mainMixerNode using the STEREO audioProcessingFormat.
    audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: audioProcessingFormat)
    
    audioEngine.prepare()
    
    do {
      try audioEngine.start()
      isEngineSetupSuccessfully = true
      print("ToneGenerator: Audio engine started successfully (Player Node Processing: Stereo).")
      return true
    } catch {
      print("ToneGenerator: Error starting audio engine: \(error.localizedDescription)")
      isEngineSetupSuccessfully = false
      return false
    }
  }
  
  func playTone(frequency: Double, intensityDb: Double, panPosition: Float, duration: TimeInterval = 1.0) {
    print("ToneGenerator: playTone - Freq: \(frequency), dB: \(intensityDb), Pan: \(panPosition)")
    
    guard setupAudioEngineIfNeeded() else {
      print("ToneGenerator: Audio engine setup failed. Aborting playTone.")
      return
    }
    
    guard audioEngine.isRunning else {
      print("ToneGenerator: Engine reported not running. Aborting playTone.")
      isEngineSetupSuccessfully = false
      return
    }
    
    playerNode.stop()
    
    playerNode.pan = panPosition // Pan works on the node's output, which is stereo.
    print("ToneGenerator: playerNode.pan set to \(playerNode.pan)")
    
    let amplitudeValue = amplitude(forDb: intensityDb)
    guard amplitudeValue > 0.00001 else {
      print("ToneGenerator: Amplitude is effectively zero.")
      return
    }
    
    let sampleRate = Float(audioProcessingFormat.sampleRate)
    let capacity = AVAudioFrameCount(sampleRate * Float(duration))
    
    // Create a STEREO buffer, matching the playerNode's processing format.
    guard let buffer = AVAudioPCMBuffer(pcmFormat: audioProcessingFormat, frameCapacity: capacity) else {
      print("ToneGenerator: Failed to create STEREO PCM buffer")
      return
    }
    buffer.frameLength = capacity
    
    // Get pointers to both left and right channel data.
    guard let leftChannel = buffer.floatChannelData?[0],
          let rightChannel = buffer.floatChannelData?[1] else {
      print("ToneGenerator: Failed to get float channel data from stereo buffer.")
      return
    }
    
    // Generate the mono sine wave and write it to BOTH channels of the stereo buffer.
    // The .pan property will then attenuate these channels appropriately.
    // If you only write to one channel here (e.g., leftChannel only), then
    // panning full right would result in silence if the pan implementation is a simple attenuation.
    // By putting the mono signal in both, pan has something to work with on both sides.
    for frame in 0..<Int(capacity) {
      let time = Float(frame) / sampleRate
      let monoSignal = sin(2.0 * .pi * Float(frequency) * time) * amplitudeValue
      leftChannel[frame] = monoSignal
      rightChannel[frame] = monoSignal
    }
    
    playerNode.scheduleBuffer(buffer) { // Schedule the STEREO buffer
      DispatchQueue.main.async {
        // print("ToneGenerator: Buffer finished playing for Freq: \(frequency)")
      }
    }
    
    if !playerNode.isPlaying {
      playerNode.play()
      print("ToneGenerator: playerNode.play() called.")
    }
  }
  
  // ... (stopTone, handleInterruptionBegan, handleInterruptionEnded remain the same)
  func stopTone() {
    guard isEngineSetupSuccessfully, audioEngine.isRunning, playerNode != nil else {
      return
    }
    if playerNode.isPlaying {
      playerNode.stop()
    }
  }
  
  func handleInterruptionBegan() {
    print("ToneGenerator: Handling interruption began or app resigning active.")
    if isEngineSetupSuccessfully && audioEngine.isRunning {
      audioEngine.pause()
      print("ToneGenerator: Audio engine paused due to interruption/backgrounding.")
    }
  }
  
  func handleInterruptionEnded() {
    print("ToneGenerator: Handling interruption ended or app became active.")
    if isEngineSetupSuccessfully {
      if !setupAudioEngineIfNeeded() {
        print("ToneGenerator: Failed to resume audio engine after interruption.")
      } else {
        print("ToneGenerator: Audio engine resumed/restarted after interruption.")
      }
    } else {
      print("ToneGenerator: Engine was not previously setup, will setup on next play request.")
    }
  }
}
