//
//  NewsViewControlller.swift
//  NewsApp
//
//  Created by Ichsan Indra Wahyudi on 25/09/24.
//

import Combine
import Foundation
import UIKit

final class NewsViewControlller: UIViewController {
    private let viewModel = NewsViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "News"
        view.backgroundColor = .white
        
        setupNavigationAppearance()
        bindViewModel()
        
        viewModel.getArticles()
        viewModel.getBlogs()
        viewModel.getReports()
    }
    
    private func setupNavigationAppearance() {
        let appearance = UINavigationBarAppearance()
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    private func bindViewModel() {
        viewModel.$stateArticle
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                print(">>> state ARTICLE: \(state)")
            }
            .store(in: &cancellables)
        
        viewModel.$stateBlog
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                print(">>> state BLOG: \(state)")
            }
            .store(in: &cancellables)
        
        viewModel.$stateReport
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                print(">>> state REPORT: \(state)")
            }
            .store(in: &cancellables)
        
    }
}

