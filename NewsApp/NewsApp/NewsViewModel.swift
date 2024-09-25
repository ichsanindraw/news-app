//
//  NewsViewModel.swift
//  NewsApp
//
//  Created by Ichsan Indra Wahyudi on 25/09/24.
//

import Combine
import UIKit

class NewsViewModel {
    private let networkManager: NetworkManager
    private var cancellables = Set<AnyCancellable>()
    
    @Published var stateArticle: ViewState<BaseResponse<[Article]>> = .loading
    @Published var stateBlog: ViewState<BaseResponse<[Blog]>> = .loading
    @Published var stateReport: ViewState<BaseResponse<[Report]>> = .loading
    
    init(
        backgroundImage: UIImage? = nil,
        networkManager: NetworkManager = NetworkManager()
    ) {
        self.networkManager = networkManager
    }

    func getArticles() {
        networkManager.request(.article, [Article].self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case let .failure(error):
                    self?.stateArticle = .error(error.localizedDescription)
                }

            }, receiveValue: { [weak self] data in
                self?.stateArticle = .success(data)
            })
            .store(in: &cancellables)
    }
    
    func getBlogs() {
        networkManager.request(.blog, [Blog].self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case let .failure(error):
                    self?.stateBlog = .error(error.localizedDescription)
                }

            }, receiveValue: { [weak self] data in
                self?.stateBlog = .success(data)
            })
            .store(in: &cancellables)
    }
    
    func getReports() {
        networkManager.request(.report, [Report].self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case let .failure(error):
                    self?.stateReport = .error(error.localizedDescription)
                }

            }, receiveValue: { [weak self] data in
                self?.stateReport = .success(data)
            })
            .store(in: &cancellables)
    }
}

