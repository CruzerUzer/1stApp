//
//  LevelBubbleView.swift
//  1stApp
//
//  Created on iOS
//

import SwiftUI
import CoreMotion
import Combine

class MotionManager: ObservableObject {
    private let motionManager = CMMotionManager()
    @Published var pitch: Double = 0.0
    @Published var roll: Double = 0.0
    @Published var isActive: Bool = false
    
    init() {
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0 // 60 Hz
    }
    
    func startUpdates() {
        guard motionManager.isDeviceMotionAvailable else {
            print("Device motion is not available")
            isActive = false
            return
        }
        
        // Ensure isActive starts as false - it will only be set to true when we receive valid data
        isActive = false
        
        // Start motion updates - callback is invoked on .main queue
        // isActive will only be set to true when we actually receive valid motion data
        // This ensures isActive accurately reflects the true state of motion monitoring
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let self = self else { return }
            
            // Callback is already on .main queue, so we can update @Published properties directly
            if let error = error {
                print("Motion update error: \(error.localizedDescription)")
                // Error occurred - motion updates are not working properly
                self.isActive = false
                return
            }
            
            guard let motion = motion else {
                // No motion data received - updates may not be active yet
                // Keep isActive false until we get valid data
                return
            }
            
            // Successfully receiving motion data - mark as active
            // Only set to true when we confirm we're actually getting data
            // This ensures isActive accurately reflects the true state of motion monitoring
            if !self.isActive {
                self.isActive = true
            }
            
            // Pitch: rotation around X-axis (forward/backward tilt)
            // Roll: rotation around Y-axis (left/right tilt)
            self.pitch = motion.attitude.pitch
            self.roll = motion.attitude.roll
        }
        
        // Verify that motion updates actually started
        // Use a delayed check to handle the asynchronous nature of motion updates
        // This ensures we catch cases where startDeviceMotionUpdates silently fails
        // or where the callback never receives data
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            guard let self = self else { return }
            
            // If motion updates aren't active, ensure isActive is false
            if !self.motionManager.isDeviceMotionActive {
                self.isActive = false
                print("Motion updates failed to start or stopped unexpectedly")
            }
            // If motion updates are active but we haven't received data yet,
            // isActive will remain false until the callback receives valid data
            // This is the correct behavior - isActive should only be true when
            // we're actually receiving motion data, not just when updates are started
        }
    }
    
    func stopUpdates() {
        motionManager.stopDeviceMotionUpdates()
        isActive = false
    }
    
    deinit {
        stopUpdates()
    }
}

struct LevelBubbleView: View {
    @StateObject private var motionManager = MotionManager()
    @State private var showInstructions = false
    
    // Constants for bubble physics
    private let bubbleRadius: CGFloat = 30
    private let levelRadius: CGFloat = 150
    private let sensitivity: Double = 0.3 // Adjust sensitivity of bubble movement
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.green.opacity(0.7), Color.blue.opacity(0.7)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Title
                Text("Level Bubble")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 2)
                    .padding(.top, 20)
                
                // Level indicator
                ZStack {
                    // Outer circle
                    Circle()
                        .stroke(Color.white.opacity(0.8), lineWidth: 4)
                        .frame(width: levelRadius * 2, height: levelRadius * 2)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
                    
                    // Crosshair lines
                    // Horizontal line
                    Rectangle()
                        .fill(Color.white.opacity(0.6))
                        .frame(width: levelRadius * 2, height: 2)
                    
                    // Vertical line
                    Rectangle()
                        .fill(Color.white.opacity(0.6))
                        .frame(width: 2, height: levelRadius * 2)
                    
                    // Center dot
                    Circle()
                        .fill(Color.white.opacity(0.9))
                        .frame(width: 8, height: 8)
                    
                    // Bubble
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.95),
                                    Color.blue.opacity(0.7)
                                ]),
                                center: .topLeading,
                                startRadius: 5,
                                endRadius: bubbleRadius
                            )
                        )
                        .frame(width: bubbleRadius * 2, height: bubbleRadius * 2)
                        .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 4)
                        .offset(
                            x: CGFloat(motionManager.roll * sensitivity * Double(levelRadius)),
                            y: CGFloat(motionManager.pitch * sensitivity * Double(levelRadius))
                        )
                        .animation(.spring(response: 0.2, dampingFraction: 0.8), value: motionManager.pitch)
                        .animation(.spring(response: 0.2, dampingFraction: 0.8), value: motionManager.roll)
                }
                .padding(.vertical, 40)
                
                // Angle display
                VStack(spacing: 10) {
                    HStack(spacing: 30) {
                        VStack {
                            Text("Pitch")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.9))
                            Text("\(motionManager.pitch * 180.0 / .pi, specifier: "%.1f")°")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        
                        VStack {
                            Text("Roll")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.9))
                            Text("\(motionManager.roll * 180.0 / .pi, specifier: "%.1f")°")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.white.opacity(0.2))
                            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
                    )
                }
                
                // Level indicator text
                let isLevel = abs(motionManager.pitch) < 0.05 && abs(motionManager.roll) < 0.05
                if isLevel && motionManager.isActive {
                    Text("LEVEL! 🎯")
                        .font(.headline)
                        .foregroundColor(.green)
                        .padding()
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.3))
                        )
                        .transition(.scale.combined(with: .opacity))
                }
                
                Spacer()
                
                // Control buttons
                HStack(spacing: 20) {
                    Button(action: {
                        showInstructions.toggle()
                    }) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                            Text("Instructions")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(12)
                    }
                    
                    Button(action: {
                        if motionManager.isActive {
                            motionManager.stopUpdates()
                        } else {
                            motionManager.startUpdates()
                        }
                    }) {
                        HStack {
                            Image(systemName: motionManager.isActive ? "stop.circle.fill" : "play.circle.fill")
                            Text(motionManager.isActive ? "Stop" : "Start")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: motionManager.isActive ? [Color.red.opacity(0.8), Color.orange.opacity(0.8)] : [Color.green.opacity(0.8), Color.blue.opacity(0.8)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
            }
        }
        .onAppear {
            motionManager.startUpdates()
        }
        .onDisappear {
            motionManager.stopUpdates()
        }
        .sheet(isPresented: $showInstructions) {
            InstructionsView()
        }
    }
}

struct InstructionsView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("How to Use the Level Bubble")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.bottom, 10)
                        
                        InstructionRow(
                            icon: "play.circle.fill",
                            title: "Start",
                            description: "Tap the Start button to begin measuring. The app will use your device's motion sensors."
                        )
                        
                        InstructionRow(
                            icon: "move.3d",
                            title: "Tilt Your Device",
                            description: "Gently tilt your iPhone or iPad in any direction. The bubble will move to show the current angle."
                        )
                        
                        InstructionRow(
                            icon: "target",
                            title: "Find Level",
                            description: "When the bubble is centered on the crosshairs, your device is level! You'll see a 'LEVEL! 🎯' message."
                        )
                        
                        InstructionRow(
                            icon: "ruler",
                            title: "Read Angles",
                            description: "Pitch shows forward/backward tilt. Roll shows left/right tilt. Values are in degrees."
                        )
                        
                        InstructionRow(
                            icon: "stop.circle.fill",
                            title: "Stop",
                            description: "Tap Stop to pause measurements and save battery life."
                        )
                        
                        Text("💡 Tip: Place your device on a surface to check if it's level, or hold it to measure angles!")
                            .font(.callout)
                            .italic()
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.top, 10)
                    }
                    .padding(30)
                }
            }
            .navigationTitle("Instructions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

struct InstructionRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.9))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.2))
        )
    }
}

#Preview {
    LevelBubbleView()
}
