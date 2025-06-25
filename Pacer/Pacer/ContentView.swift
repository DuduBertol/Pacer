//
//  ContentView.swift
//  Pacer
//
//  Created by Eduardo Bertol on 25/06/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var stravaManager = StravaManager()
    @State private var showLoginSheet = false
    
    // Dados da atividade de exemplo
    @State private var activityName = "Minha Corrida SwiftUI"
    @State private var activityDurationSeconds = 3600 // 1 hora
    @State private var activityDistanceMeters: Float = 5000 // 5km

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let token = stravaManager.accessToken {
                    Text("Autenticado no Strava!")
                        .font(.headline)
                        .foregroundColor(.green)
                    
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Postar Nova Atividade").font(.title2)
                        TextField("Nome da Atividade", text: $activityName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        HStack {
                           Text("Duração (segundos):")
                           TextField("Segundos", value: $activityDurationSeconds, formatter: NumberFormatter())
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                        }
                        
                        HStack {
                           Text("Distância (metros):")
                           TextField("Metros", value: $activityDistanceMeters, format: .number)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                        }
                        
                        Button("Postar Atividade no Strava") {
                            stravaManager.createActivity(
                                name: activityName,
                                type: "Run",
                                elapsedTimeInSeconds: activityDurationSeconds,
                                distanceInMeters: activityDistanceMeters
                            )
                        }
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)

                    
                    Button("Logout do Strava") {
                        stravaManager.logout()
                    }
                    .foregroundColor(.red)

                } else {
                    Text("Não autenticado")
                        .font(.headline)
                        .foregroundColor(.red)

                    Button("Conectar com Strava") {
                        if stravaManager.authorizationURL != nil {
                            showLoginSheet = true
                        }
                    }
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                
                Spacer()
                
                Text(stravaManager.lastResponseMessage)
                    .padding()
                    .multilineTextAlignment(.center)
            }
            .padding()
            .navigationTitle("App de Corrida")
            // A view é atualizada quando o app volta do browser com a URL de redirect
            .onOpenURL { url in
                // Aqui o app captura a URL de callback
                showLoginSheet = false
                stravaManager.handleAuthorizationCode(url: url)
            }
            .sheet(isPresented: $showLoginSheet) {
                // A folha modal que mostra a página de login do Strava
                if let url = stravaManager.authorizationURL {
                    NavigationView {
                        StravaLoginView(url: url)
                            .navigationTitle("Login Strava")
                            .navigationBarItems(leading: Button("Cancelar") {
                                showLoginSheet = false
                            })
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
