//
//  ActivityView.swift
//  Pacer
//
//  Created by Eduardo Bertol on 25/06/25.
//

import SwiftUI

struct ActivityView: View {
    
    @State var showModal: Bool = false
    
    var body: some View {
        VStack{
            Button{
                showModal = true
            }label:{
                Text("Open Modal")
            }
        }
        .sheet(isPresented: $showModal){
            StartActivityModal()
                .presentationDetents([.medium])

        }
    }
}

#Preview {
    ActivityView()
}
