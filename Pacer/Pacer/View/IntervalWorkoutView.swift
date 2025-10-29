//
//  IntervalWorkoutView.swift
//  Pacer
//
//  Created by Eduardo Bertol on 22/08/25.
//

import SwiftUI

struct IntervalWorkoutView: View {
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var vm: IntervalWorkoutViewModel
    
    @State var showResetAlert: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            
            if vm.isFinished {
                Text("Treino Finalizado!")
                    .font(.title)
            }
            else if vm.currentIntervalIndex < vm.intervals.count {
                let current = vm.intervals[vm.currentIntervalIndex]
                
                Text(current.name)
                    .font(.title)
                
                Text(formatTime(current.duration - vm.elapsedTime))
                    .font(.system(size: 60, weight: .bold, design: .rounded))
            }
            
            HStack(spacing: 32) {
                Button {
                    vm.isRunning ? vm.stop() : vm.start()
                } label:{
                    Image(systemName: vm.isRunning ? SFNames.pause.rawValue : SFNames.play.rawValue)
                }
                
                Button{
                    vm.stop()
                    showResetAlert = true
                } label:{
                    Image(systemName: SFNames.stop.rawValue)
                }
                .alert("Encerrar treino?", isPresented: $showResetAlert) {
                    Button("Sim", role: .destructive) {
                        vm.finish()
                    }
                    Button("Cancelar", role: .cancel) {}
                }
            }
            .font(.title)
            .padding()
        }
        .padding()
        .sheet(isPresented: $vm.isFinished) {
            SummaryView(vm: vm)
        }
    }
    
    func formatTime(_ time: TimeInterval) -> String {
        let total = max(0, Int(time))
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    IntervalWorkoutView(vm: IntervalWorkoutViewModel())
}
