//
//  SummaryView.swift
//  Pacer
//
//  Created by Eduardo Bertol on 26/08/25.
//

import SwiftUI

struct SummaryView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var vm: IntervalWorkoutViewModel
    
    var body: some View {
        VStack(spacing: 16){
            Text("Treino finalizado")
                .font(.title)
                
            Text(vm.totalTimeString)
                .font(.system(size: 48, weight: .bold, design: .rounded))
                
            Button{
                vm.reset()
                dismiss()
            } label: {
                Text("Fechar")
            }
        }
    }
}

#Preview {
    SummaryView(vm: IntervalWorkoutViewModel())
}
