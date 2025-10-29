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
        VStack{
            Form{
                Section("Field Size (m)"){
                    Button{
                        withAnimation{
                            isOpenedMetersWheel.toggle()
                        }
                    } label: {
                        HStack{
                            Text("\(Int($vm.fieldSize.wrappedValue)) meters")
                            Spacer()
                            Image(systemName: isOpenedMetersWheel ? "chevron.up" : "chevron.down")
                        }
                    }
                    
                    if isOpenedMetersWheel {
                        Picker("Field Size", selection: $vm.fieldSize) {
                            ForEach(1..<1000){
                                Text("\($0) m")
                            }
                        }
                        .pickerStyle(.wheel)
                        .foregroundStyle(.red)
                    }
                }
                
                Section("Elapsed Time"){
                    HStack{
                        Spacer()
                        Text(formatTime(vm.elapsedTime))
                            .font(.largeTitle)
                            .bold()
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                }
                
                Section("Pace (min/Km)"){
                    HStack{
                        Spacer()
                        Text("\(formatTime($vm.pace.wrappedValue))")
                            .font(.largeTitle)
                            .bold()
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                }
                
                
                Section{
                    Button{
                        vm.calculatePace()
                        vm.newRound()
                    } label: {
                        HStack{
                            Spacer()
                            Text("Volta")
                                .font(.title)
                                .padding()
                            Spacer()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button{
                        vm.stop()
                    } label: {
                        HStack{
                            Spacer()
                            Text("Stop")
                                .font(.caption)
                            Spacer()
                        }
                    }
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
    
    @State var fieldSize: Double = 260 //meters
    @Published var elapsedTime: TimeInterval = 0 //seconds

    @State var pace: Double = 0
    
    @Published var isRunning = false
    
    
    private var startDate: Date?
    private var accumulatedTime: TimeInterval = 0
    private var timerCancellable: AnyCancellable?
    
    private var totalTime: TimeInterval = 0
    @Published var totalTimeString: String = "00m00s"
    
    
    // MARK: - Controle do treino
    func newRound() {
        stop()
        
        isRunning = true
        startDate = Date()
        
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
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
        
        totalTime += elapsedTime
    }
    
    func calculatePace(){
        let km: Double = 1000 / fieldSize
        let minutes: Double = elapsedTime / 60
        
        pace = minutes / km
//        pace = (1000 / fieldSize) / (elapsedTime / 60)
        
        print("pace: \(pace)")
    }
}
