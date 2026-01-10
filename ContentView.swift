//
//  ContentView.swift
//  1stApp
//
//  Created by Adam Faris on 2026-01-10.
//

import SwiftUI

struct ContentView: View {
    @State private var counter = 0
    @State private var showAlert = false
    @State private var name = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Welcome section
                    VStack(spacing: 10) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.yellow)
                            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 5)
                        
                        Text("Welcome to 1stApp!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
                        
                        if !name.isEmpty {
                            Text("Hello, \(name)!")
                                .font(.title2)
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                    .padding(.top, 40)
                    
                    // Counter section
                    VStack(spacing: 20) {
                        Text("Counter")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.9))
                        
                        Text("\(counter)")
                            .font(.system(size: 72, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 5)
                        
                        HStack(spacing: 20) {
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    counter -= 1
                                }
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 3)
                            }
                            
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    counter = 0
                                }
                            }) {
                                Text("Reset")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(15)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(Color.white.opacity(0.5), lineWidth: 2)
                                    )
                            }
                            
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    counter += 1
                                }
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 3)
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.15))
                            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                    )
                    .padding(.horizontal, 30)
                    
                    // Name input section
                    VStack(spacing: 15) {
                        Text("Enter your name")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.9))
                        
                        TextField("Your name", text: $name)
                            .textFieldStyle(.plain)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(15)
                            .foregroundColor(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.white.opacity(0.5), lineWidth: 2)
                            )
                            .padding(.horizontal, 30)
                    }
                    
                    // Action button
                    Button(action: {
                        showAlert = true
                    }) {
                        HStack {
                            Image(systemName: "hand.wave.fill")
                            Text("Say Hello")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.orange, Color.pink]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(15)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 5)
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                }
            }
            .navigationTitle("1stApp")
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Hello!"),
                    message: Text(name.isEmpty ? "Welcome to your first app! 🎉" : "Hello, \(name)! Welcome to your first app! 🎉"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}

#Preview {
    ContentView()
}
