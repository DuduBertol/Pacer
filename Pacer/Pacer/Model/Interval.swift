//
//  Interval.swift
//  Pacer
//
//  Created by Eduardo Bertol on 22/08/25.
//

import Foundation
import SwiftUI

struct Interval: IntervalProtocol {
    let id: UUID = UUID()
    var name: String
    var symbol: SFNames
    var color: Color
    var duration: TimeInterval = 30
}



