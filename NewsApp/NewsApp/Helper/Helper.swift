//
//  Helper.swift
//  NewsApp
//
//  Created by Ichsan Indra Wahyudi on 26/09/24.
//

import Foundation

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
