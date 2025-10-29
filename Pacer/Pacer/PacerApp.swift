//
//  PacerApp.swift
//  Pacer
//
//  Created by Eduardo Bertol on 25/06/25.
//

import SwiftUI
import UserNotifications

@main
struct PacerApp: App {
    
    init() {
        configureNotifications()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
//                .preferredColorScheme(.light)
        }
    }
    
    private func configureNotifications() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Erro ao pedir permissão: \(error)")
            } else {
                print("Permissão concedida? \(granted)")
            }
        }
        center.delegate = NotificationDelegate.shared
    }
}

// MARK: - Delegate para exibir notificações em foreground
class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Força aparecer mesmo com app aberto
        completionHandler([.banner, .sound])
    }
}
