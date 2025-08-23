//
//  StopwatchView.swift
//  Pacer
//
//  Created by Eduardo Bertol on 22/08/25.
//

import SwiftUI

struct StopwatchView: View {
    @State private var startDate: Date? = nil
    @State private var isRunning = false
    @State private var elapsedTime: TimeInterval = 0
    
    // Atualizador de UI em foreground
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 20) {
            Text(formatTime(elapsedTime))
                .font(.system(size: 48, weight: .bold, design: .monospaced))
            
            HStack {
                Button(isRunning ? "Parar" : "Iniciar") {
                    if isRunning {
                        // parar
                        elapsedTime = Date().timeIntervalSince(startDate ?? Date())
                        isRunning = false
                    } else {
                        // iniciar
                        startDate = Date().addingTimeInterval(-elapsedTime)
                        isRunning = true
                    }
                }
                
                Button("Zerar") {
                    elapsedTime = 0
                    startDate = nil
                    isRunning = false
                }
            }
        }
        .onReceive(timer) { _ in
            guard isRunning, let start = startDate else { return }
            elapsedTime = Date().timeIntervalSince(start)
        }
    }
    
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    StopwatchView()
}
