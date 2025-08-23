//
//  IntervalProtocol.swift
//  Pacer
//
//  Created by Eduardo Bertol on 23/08/25.
//

import Foundation
import SwiftUICore

protocol IntervalProtocol: Identifiable {
    var id: UUID { get }
    var name: String { get }
    var symbol: SFNames { get }
    var color: Color { get }
    var duration: TimeInterval { get set }
    var durationString: String { get }
}

extension IntervalProtocol {
    var durationString: String {
        String(format: "%02dm%02ds", Int(duration.truncatingRemainder(dividingBy: 3600)) / 60, Int(duration.truncatingRemainder(dividingBy: 60)))
    }
    
}
