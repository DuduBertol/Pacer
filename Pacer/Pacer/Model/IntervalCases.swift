//
//  IntervalCases.swift
//  Pacer
//
//  Created by Eduardo Bertol on 23/08/25.
//

import Foundation
import SwiftUICore

enum IntervalCases: CaseIterable {
    case leve, moderado, forte
    
    private var name: String {
        switch self {
        case .leve: return "Leve"
        case .moderado: return "Moderado"
        case .forte: return "Forte"
        }
    }
    
    private var symbol: SFNames {
        switch self {
        case .leve: return .leve
        case .moderado: return .moderado
        case .forte: return .forte
        }
    }
    
    private var color: Color {
        switch self {
            case .leve: return .sBlue
            case .moderado: return .sYellow
            case .forte: return .sRed
        }
    }
    
    /// Cria um `Interval` pronto a partir do caso
    var interval: Interval {
        Interval(name: name, symbol: symbol, color: color)
    }
    
}
