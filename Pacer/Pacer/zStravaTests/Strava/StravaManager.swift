//
//  StravaManager.swift
//  Pacer
//
//  Created by Eduardo Bertol on 25/06/25.
//

import Foundation
import SwiftUI
import WebKit

// --- Classe para gerenciar a lógica do Strava ---
class StravaManager: ObservableObject {
    // IMPORTANTE: Substitua com suas credenciais do app Strava
    private let clientID = "SEU_CLIENT_ID"
    private let clientSecret = "SEU_CLIENT_SECRET"
    private let redirectURI = "seuapp://exchange_token" // Deve ser o mesmo do seu app Strava e Xcode

    // Publicamos o token para que a UI possa reagir às mudanças de estado
    @Published var accessToken: String?
    @Published var lastResponseMessage: String = ""

    init() {
        // Tente carregar o token salvo ao iniciar
        self.accessToken = UserDefaults.standard.string(forKey: "stravaAccessToken")
    }

    // 1. Iniciar o processo de autenticação
    var authorizationURL: URL? {
        var components = URLComponents(string: "https://www.strava.com/oauth/authorize")
        components?.queryItems = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "approval_prompt", value: "auto"),
            // Scope define as permissões. 'activity:write' é para criar atividades.
            URLQueryItem(name: "scope", value: "activity:write,activity:read")
        ]
        return components?.url
    }

    // 2. Lidar com o código de autorização recebido via URL Scheme
    func handleAuthorizationCode(url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
            print("Não foi possível extrair o código de autorização da URL.")
            return
        }
        
        exchangeCodeForToken(code: code)
    }

    // 3. Trocar o código de autorização pelo token de acesso
    private func exchangeCodeForToken(code: String) {
        guard let url = URL(string: "https://www.strava.com/oauth/token") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let parameters: [String: Any] = [
            "client_id": clientID,
            "client_secret": clientSecret,
            "code": code,
            "grant_type": "authorization_code"
        ]
        
        request.httpBody = parameters.map { "\($0.key)=\($0.value)" }.joined(separator: "&").data(using: .utf8)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.lastResponseMessage = "Erro na requisição do token: \(error.localizedDescription)"
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.lastResponseMessage = "Nenhum dado recebido na resposta do token."
                }
                return
            }

            do {
                let tokenResponse = try JSONDecoder().decode(StravaTokenResponse.self, from: data)
                DispatchQueue.main.async {
                    self.accessToken = tokenResponse.access_token
                    // Salvar o token de forma segura (UserDefaults é apenas para exemplo)
                    // Em um app real, use o Keychain para armazenar tokens!
                    UserDefaults.standard.set(self.accessToken, forKey: "stravaAccessToken")
                    UserDefaults.standard.set(tokenResponse.refresh_token, forKey: "stravaRefreshToken")
                    self.lastResponseMessage = "Autenticação bem-sucedida! Token recebido."
                }
            } catch {
                DispatchQueue.main.async {
                    self.lastResponseMessage = "Falha ao decodificar a resposta do token: \(error)"
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("Resposta do servidor: \(responseString)")
                    }
                }
            }
        }.resume()
    }

    // 4. Postar uma nova atividade
    func createActivity(name: String, type: String, elapsedTimeInSeconds: Int, distanceInMeters: Float) {
        guard let token = accessToken else {
            self.lastResponseMessage = "Erro: Access Token não encontrado. Autentique primeiro."
            return
        }
        
        guard let url = URL(string: "https://www.strava.com/api/v3/activities") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let dateFormatter = ISO8601DateFormatter()
        let startDate = dateFormatter.string(from: Date())

        let parameters: [String: Any] = [
            "name": name,
            "type": type, // Ex: "Run", "Ride", "Walk"
            "start_date_local": startDate,
            "elapsed_time": elapsedTimeInSeconds,
            "description": "Atividade postada pelo meu App de Corrida!",
            "distance": distanceInMeters
        ]
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
            return
        }
        
        request.httpBody = httpBody

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let httpResponse = response as? HTTPURLResponse {
                    if (200...299).contains(httpResponse.statusCode) {
                        self.lastResponseMessage = "Sucesso! Atividade criada no Strava."
                    } else {
                        self.lastResponseMessage = "Erro ao criar atividade. Status: \(httpResponse.statusCode)"
                        if let data = data, let responseBody = String(data: data, encoding: .utf8) {
                            self.lastResponseMessage += "\nResposta: \(responseBody)"
                        }
                    }
                } else if let error = error {
                    self.lastResponseMessage = "Erro de rede: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
    
    func logout() {
        self.accessToken = nil
        UserDefaults.standard.removeObject(forKey: "stravaAccessToken")
        UserDefaults.standard.removeObject(forKey: "stravaRefreshToken")
        self.lastResponseMessage = "Você foi desconectado."
    }
}
