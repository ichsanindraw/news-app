//
//  Helper.swift
//  NewsApp
//
//  Created by Ichsan Indra Wahyudi on 26/09/24.
//

import Foundation
import UserNotifications

func getGreeting() -> String {
    let hour = Calendar.current.component(.hour, from: Date())

    switch hour {
    case 5..<12:
        return "Good Morning"
    case 12..<17:
        return "Good Afternoon"
    case 17..<21:
        return "Good Evening"
    default:
        return "Good Night"
    }
}

func formatedDate(_ value: String) -> String? {
    let inputFormatter = ISO8601DateFormatter()
    
    guard let date = inputFormatter.date(from: value) else {
        return nil
    }
    
    let outputFormatter = DateFormatter()
    outputFormatter.locale = Locale(identifier: "id_ID")
    outputFormatter.dateFormat = "dd MMMM yyyy, HH:mm"
    
    outputFormatter.timeZone = TimeZone.current
    
    return outputFormatter.string(from: date)
}

func extractFirstSentence(from text: String) -> String {
    if let firstPeriodIndex = text.firstIndex(of: ".") {
        let firstSentence = text[..<firstPeriodIndex]
        return String(firstSentence).trimmingCharacters(in: .whitespacesAndNewlines)
    }
    return text
}

//func checkAutoLogout() {
//    if let loginTime = UserDefaults.standard.object(forKey: Constants.loginTimeKey) as? Date {
//        let currentTime = Date()
//        let timeInterval = currentTime.timeIntervalSince(loginTime)
//
//        // Jika lebih dari 10 menit (600 detik)
//        if timeInterval > 600 {
//            logoutUser()
//        }
//    }
//}

//func logoutUser() {
//    // Logika untuk logout pengguna
//    UserDefaults.standard.removeObject(forKey: Constants.loginTimeKey)
//    
//    // Kirim push notifikasi
//    let content = UNMutableNotificationContent()
//    content.title = "Logout"
//    content.body = "Akun Anda sudah terlogout otomatis."
//
//    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
//    let request = UNNotificationRequest(identifier: "logoutNotification", content: content, trigger: trigger)
//
//    UNUserNotificationCenter.current().add(request) { error in
//        if let error = error {
//            print("Error sending notification: \(error)")
//        }
//    }
//}

func sendLogoutNotification() {
    let content = UNMutableNotificationContent()
    content.title = "Session Expired"
    content.body = "Akun Anda sudah terlogout secara otomatis setelah 10 menit tidak aktif."
    content.sound = UNNotificationSound.default

    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
    let request = UNNotificationRequest(identifier: "logoutNotification", content: content, trigger: trigger)

    UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
            print("Failed to send logout notification: \(error)")
        } else {
            print("Logout notification sent successfully.")
        }
    }
}
