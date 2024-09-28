//
//  Constants.swift
//  NewsApp
//
//  Created by Ichsan Indra Wahyudi on 25/09/24.
//

import Foundation

struct Constants {
    static let API_URL = (Bundle.main.infoDictionary?["API_URL"] as? String) ?? ""

    static let recentSearchKey = "recentSearch"
    static let lastLoginTimeKey = "lastLoginTime"
    static let loggedInUserDataKey = "loggedInUserData"
    
    // 10 menit
    static let loginDuration: Double = 6000 // 600
}
