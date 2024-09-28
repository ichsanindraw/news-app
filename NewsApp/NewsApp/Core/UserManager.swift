//
//  UserManager.swift
//  NewsApp
//
//  Created by Ichsan Indra Wahyudi on 28/09/24.
//

import Combine
import Foundation

class UserManager {
    static let shared = UserManager()
    
    private let networkManager = NetworkManager()
    private var cancellables = Set<AnyCancellable>()
    
    func logout(completion: @escaping (Result<Void, Error>) -> Void) {
        networkManager.logout()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
//                    completion(.success(()))
                    break
                case let .failure(error):
                    print("Logout failed: \(error)")
//                    completion(.failure(error))
                    break
                }
            } receiveValue: { isSuccess in
                KeychainManager.shared.deleteAccessToken()
                UserDefaults.standard.removeObject(forKey: Constants.lastLoginTimeKey)
                UserDefaults.standard.removeObject(forKey: Constants.loggedInUserDataKey)
                
                DispatchQueue.main.async {
                    sendLogoutNotification()
                }
            }
            .store(in: &cancellables)
    }
    
    func getUserData() -> StoredUserData? {
        let decoder = JSONDecoder()
        if let data = UserDefaults.standard.data(forKey: Constants.loggedInUserDataKey) {
            do {
                let userData = try decoder.decode(StoredUserData.self, from: data)
                return userData
            } catch {
                print("Error decoding user data: \(error.localizedDescription)")
            }
        }
        return nil
    }
    

}
