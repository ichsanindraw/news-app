//
//  Helper.swift
//  NewsApp
//
//  Created by Ichsan Indra Wahyudi on 26/09/24.
//

import Foundation
import UserNotifications
import UIKit

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

func isValidEmail(_ email: String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    return NSPredicate(format: "SELF MATCHES %@", emailRegEx).evaluate(with: email)
}

func saveRecentSearch(query: String) {
    var recentSearches = UserDefaults.standard.stringArray(forKey: Constants.recentSearchKey) ?? []
        
    // Avoid duplicates and limit to 5 recent searches
    if !recentSearches.contains(query) && !query.isEmpty {
        recentSearches.insert(query, at: 0)
    }
    
    // Keep only the last 5 searches
    if recentSearches.count > 5 {
        recentSearches = Array(recentSearches.prefix(5))
    }
    
    UserDefaults.standard.set(recentSearches, forKey: Constants.recentSearchKey)
}

func requestNotificationPermissions() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        if granted {
            print("Permission granted")
        } else if let error = error {
            print("Permission denied: \(error.localizedDescription)")
        }
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}
