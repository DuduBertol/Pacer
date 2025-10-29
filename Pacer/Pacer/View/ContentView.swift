//
//  ContentView.swift
//  Pacer
//
//  Created by Eduardo Bertol on 27/10/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var vm = IntervalWorkoutViewModel()
    
    var body: some View {
        TabView{
            Tab{
                IntervalEditorView(vm: vm)
            } label: {
                Image(systemName: "figure.run")
            }
            Tab{
                PaceCalculator()
            } label: {
                Image(systemName: "clock.arrow.trianglehead.clockwise.rotate.90.path.dotted")
            }
        }
    }
}

#Preview {
    ContentView()
}
