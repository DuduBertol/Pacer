//
//  IntervalWorkoutViewModel.swift
//  Pacer
//
//  Created by Eduardo Bertol on 22/08/25.
//

import Foundation
import Combine
import UserNotifications

class IntervalWorkoutViewModel: ObservableObject {
    @Published var intervals: [Interval] = []
    @Published var intervalRange: ClosedRange<TimeInterval> = 30...1200 //segundos
    
    // Estado do treino
    @Published var currentIntervalIndex = 0
    @Published var elapsedTime: TimeInterval = 0
    @Published var isRunning = false
    @Published var isFinished = false
    
    
    private var startDate: Date?
    private var accumulatedTime: TimeInterval = 0
    private var timerCancellable: AnyCancellable?
    
    private var totalTime: TimeInterval = 0
    @Published var totalTimeString: String = "00m00s"
    
    
    // MARK: - Controle do treino
    func start() {
        guard !intervals.isEmpty else { return }
        
        if isFinished {
            reset() // se já terminou, recomeça do zero
        }
        
        isRunning = true
        startDate = Date() // marca novo ponto de referência
        
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }
    
    func stop() {
        isRunning = false
        if let startDate {
            accumulatedTime += Date().timeIntervalSince(startDate) // salva progresso
        }
        timerCancellable?.cancel()
    }
    
    func finish() {
        print(accumulatedTime)
        print(elapsedTime)
        
        stop()
        notifyIntervalChange(nil)
        totalTimeString = String(format: "%02dm%02ds", Int(totalTime.truncatingRemainder(dividingBy: 3600)) / 60, Int(totalTime.truncatingRemainder(dividingBy: 60)))

        isFinished = true        
    }
    
    private func tick() {
        guard let startDate, isRunning, currentIntervalIndex < intervals.count else { return }
        
        // tempo desde a última retomada
        let currentElapsed = Date().timeIntervalSince(startDate)
        elapsedTime = accumulatedTime + currentElapsed
        
        if elapsedTime >= intervals[currentIntervalIndex].duration {
            totalTime += elapsedTime
            nextInterval()
        }
    }
    
    private func nextInterval() {
        currentIntervalIndex += 1
        accumulatedTime = 0 // zera acumulado do próximo intervalo
        elapsedTime = 0
        startDate = Date()
        
        if currentIntervalIndex < intervals.count {
            notifyIntervalChange(intervals[currentIntervalIndex])
        } else {
            finish()
        }
    }
    
    func addInterval(_ intervalCase: IntervalCases) {
        intervals.append(intervalCase.interval)
    }
    
    func reset() {
        stop()
        currentIntervalIndex = 0
        elapsedTime = 0
        accumulatedTime = 0
        isFinished = false
        startDate = nil
    }
    
    // MARK: - Notificações
    private func notifyIntervalChange(_ interval: Interval?) {
        let content = UNMutableNotificationContent()
        
        if let interval {
            content.title = "Próximo intervalo"
            content.body = "\(interval.name) - \(Int(interval.duration))s"
        } else {
            content.title = "Treino concluído 🏁"
            content.body = "Parabéns!"
        }
        content.sound = .default
        
        // dispara imediatamente
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // Teste rápido de notificação
    func testNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Teste 🚀"
        content.body = "Notificação de exemplo"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
}

