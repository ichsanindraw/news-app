//
//  Constants.swift
//  NewsApp
//
//  Created by Ichsan Indra Wahyudi on 25/09/24.
//

import Foundation

struct Constants {
    static let API_URL = (Bundle.main.infoDictionary?["API_URL"] as? String) ?? ""
    
    static let bgAppTaskIdentifier = "com.newsapp.logoutTask"
    static let loginTimeKey = "loginTime"
}
