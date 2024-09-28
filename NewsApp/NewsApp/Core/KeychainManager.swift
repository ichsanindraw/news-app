//
//  KeychainManager.swift
//  NewsApp
//
//  Created by Ichsan Indra Wahyudi on 28/09/24.
//

import Foundation
import KeychainAccess

final class KeychainManager {
    static let shared = KeychainManager(service: "secure_storage")
    
    private let keychain: Keychain
    private let accessTokenKey = "accessToken"

    private init(service: String) {
        keychain = Keychain(service: service)
    }

    // Save the access token
    func saveAccessToken(token: String) {
        do {
            try keychain.set(token, key: accessTokenKey)
            print("Access token saved successfully.")
        } catch {
            print("Error saving access token: \(error.localizedDescription)")
        }
    }

    // Retrieve the access token
    func getAccessToken() -> String? {
        do {
            let token = try keychain.get(accessTokenKey)
            return token
        } catch {
            print("Error retrieving access token: \(error.localizedDescription)")
            return nil
        }
    }

    // Delete the access token
    func deleteAccessToken() {
        do {
            try keychain.remove(accessTokenKey)
            print("Access token deleted successfully.")
        } catch {
            print("Error deleting access token: \(error.localizedDescription)")
        }
    }
}
