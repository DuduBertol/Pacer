//
//  StravaTokenResponse.swift
//  Pacer
//
//  Created by Eduardo Bertol on 25/06/25.
//

import Foundation
import SwiftUI
import WebKit

// NOTA: Para este exemplo funcionar, você precisa configurar um esquema de URL
// no seu projeto Xcode. Vá em "Info" -> "URL Types" e adicione um novo
// com um identificador (ex: com.seuapp) e um esquema de URL (ex: seuapp).

// --- Modelos para decodificar a resposta do token ---
struct StravaTokenResponse: Codable {
    let token_type: String
    let expires_at: Int
    let expires_in: Int
    let refresh_token: String
    let access_token: String
    // Opcional, pois pode não vir na resposta de refresh
    let athlete: AthleteSummary?
}
