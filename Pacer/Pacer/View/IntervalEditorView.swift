//
//  IntervalEditorView.swift
//  Pacer
//
//  Created by Eduardo Bertol on 22/08/25.
//

import SwiftUI

struct IntervalEditorView: View {
    @ObservedObject var vm: IntervalWorkoutViewModel
    @State private var showingWorkout = false
    
    var body: some View {
        NavigationStack {
    
            List {
                ForEach($vm.intervals) { $interval in
                    HStack {
                        Image(systemName: $interval.symbol.wrappedValue.rawValue)
                            .foregroundStyle($interval.color.wrappedValue)
                        TextField("Nome", text: $interval.name)
                            .foregroundStyle($interval.color.wrappedValue)
                        Spacer()
                        Stepper(
                            "\(interval.durationString)",
                            value: $interval.duration,
                            in: $vm.intervalRange.wrappedValue,
                            step: 30
                        )
                        .frame(width: 180)
                    }
                }
                .onDelete { indexSet in
                    vm.intervals.remove(atOffsets: indexSet)
                }
            }
            .navigationTitle("Treino") //Title
            .toolbar {
                
                //Edit Button
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                
                //Iniciar Button
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button{
                        showingWorkout = true
                    } label:{
//                        Text(vm.isRunning ? "Retomar Treino" : "Iniciar Treino")
//                            .padding(8)
                        Image(systemName: vm.isRunning ? "pause" : "play")
                    }
//                    .buttonStyle(.borderedProminent)
                    .disabled(vm.intervals.isEmpty)
                }
                
                
                //Plus Button
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu{
                        //LEVE
                        Button{
                            vm.addInterval(IntervalCases.leve)
                        }label:{
                            Text(IntervalCases.leve.interval.name)
                            Image(systemName: SFNames.leve.rawValue)
                                .tint(IntervalCases.leve.interval.color)
                        }
                        
                        //MODERADO
                        Button{
                            vm.addInterval(IntervalCases.moderado)
                        }label:{
                            Text(IntervalCases.moderado.interval.name)
                            Image(systemName: SFNames.moderado.rawValue)
                                .tint(IntervalCases.moderado.interval.color)
                        }
                        
                        //FORTE
                        Button{
                            vm.addInterval(IntervalCases.forte)
                        }label:{
                            Text(IntervalCases.forte.interval.name)
                            Image(systemName: SFNames.forte.rawValue)
                                .tint(IntervalCases.forte.interval.color)
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingWorkout) {
                IntervalWorkoutView(vm: vm)
            }
        }
    }
}


#Preview {
    IntervalEditorView(vm: IntervalWorkoutViewModel())
}
