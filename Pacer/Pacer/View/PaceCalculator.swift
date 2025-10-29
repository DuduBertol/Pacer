//
//  PaceCalculator.swift
//  Pacer
//
//  Created by Eduardo Bertol on 27/10/25.
//
import SwiftUI
import Combine

struct PaceCalculator: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject var vm = PaceCalculatorViewModel()
    
    @State var isOpenedMetersWheel: Bool = false
    
    var body: some View {
        VStack {
            Form {
                Section("Field Size (m)") {
                    Button {
                        withAnimation {
                            isOpenedMetersWheel.toggle()
                        }
                    } label: {
                        HStack {
                            Text("\(Int(vm.fieldSize)) meters")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: isOpenedMetersWheel ? "chevron.up" : "chevron.down")
                                .foregroundColor(.accentColor)
                        }
                    }
                    .buttonStyle(.plain)
                    
                    if isOpenedMetersWheel {
                        Picker("Field Size", selection: $vm.fieldSize) {
                            ForEach(50..<1001, id: \.self) { meters in
                                Text("\(meters) m").tag(Double(meters))
                            }
                        }
                        .pickerStyle(.wheel)
                    }
                }
                
                Section("Elapsed Time") {
                    HStack {
                        Spacer()
                        Text(formatTime(vm.elapsedTime))
                            .font(.largeTitle)
                            .bold()
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                }
                
                Section("Pace (min/Km)") {
                    HStack {
                        Spacer()
                        Text(formatTime(vm.pace * 60))
                            .font(.largeTitle)
                            .bold()
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                }
                
                Section {
                    Button {
                        vm.calculatePace()
                        vm.newRound()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Volta")
                                .font(.title)
                                .padding()
                            Spacer()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button {
                        vm.stop()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Stop")
                                .font(.caption)
                            Spacer()
                        }
                    }
                    .tint(.red)
                }
            }
        }
    }
    
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    PaceCalculator()
}

class PaceCalculatorViewModel: ObservableObject {
    
    @Published var fieldSize: Double = 260 // meters
    @Published var elapsedTime: TimeInterval = 0 // seconds
    @Published var pace: Double = 0 // minutes per km
    @Published var isRunning = false
    
    private var startDate: Date?
    private var timerCancellable: AnyCancellable?
    
    private var totalTime: TimeInterval = 0
    @Published var totalTimeString: String = "00m00s"
    
    // MARK: - Controle do treino
    func newRound() {
        stop()
        
        isRunning = true
        startDate = Date()
        
        timerCancellable = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }
    
    func stop() {
        isRunning = false
        timerCancellable?.cancel()
        elapsedTime = 0
    }
    
    private func tick() {
        guard let startDate, isRunning else { return }
        
        let currentElapsed = Date().timeIntervalSince(startDate)
        elapsedTime = currentElapsed
    }
    
    func calculatePace() {
        // Distância em quilômetros
        let distanceInKm = fieldSize / 1000.0
        
        // Tempo em minutos
        let minutes = elapsedTime / 60.0
        
        // Pace = minutos por quilômetro
        pace = minutes / distanceInKm
        
        print("Distance: \(fieldSize)m (\(distanceInKm)km)")
        print("Time: \(elapsedTime)s (\(minutes)min)")
        print("Pace: \(pace) min/km")
    }
}
