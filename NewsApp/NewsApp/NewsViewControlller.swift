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
    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let listArticlesView = HorizontalListView<Article>(title: "Artikel")
    private let listBlogsView = HorizontalListView<Blog>(title: "Blog")
    private let listReportsView = HorizontalListView<Report>(title: "Report")
    
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
        
        view.backgroundColor = .white
        
        setupNavigationTitle()
        setupNavigationAppearance()
        bindViewModel()
        
        viewModel.getArticles(limit: 4)
        viewModel.getBlogs(limit: 4)
        viewModel.getReports(limit: 5)
        
        setupUI()
    }
    
    private func setupNavigationAppearance() {
        let appearance = UINavigationBarAppearance()
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    private func setupNavigationTitle() {
        let titleLabel = UILabel()
        titleLabel.text = "\(getGreeting()), Ichsan Indra Wahyudi"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textColor = .red
        
        let titleItem = UIBarButtonItem(customView: titleLabel)
        titleItem.isEnabled = false

        navigationItem.leftBarButtonItem = titleItem
    }
    
    private func bindViewModel() {
        viewModel.$stateArticle
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
//                print(">>> state ARTICLE: \(state)")
                switch state {
                case.loading:
                    break
                case .error(_):
                    break
                case let .success(data):
                    self?.listArticlesView.updateData(data.results)
                }
            }
            .store(in: &cancellables)
        
        viewModel.$stateBlog
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
//                print(">>> state BLOG: \(state)")
                switch state {
                case.loading:
                    break
                case .error(_):
                    break
                case let .success(data):
                    self?.listBlogsView.updateData(data.results)
                }
            }
            .store(in: &cancellables)
        
        viewModel.$stateReport
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
//                print(">>> state REPORT: \(state)")
                switch state {
                case.loading:
                    break
                case .error(_):
                    break
                case let .success(data):
                    self?.listReportsView.updateData(data.results)
                }
            }
            .store(in: &cancellables)
        
    }
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
               
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            
            containerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
       
        containerView.addSubview(listArticlesView)
        containerView.addSubview(listBlogsView)
        containerView.addSubview(listReportsView)
       
        NSLayoutConstraint.activate([
            listArticlesView.topAnchor.constraint(equalTo: containerView.topAnchor),
            listArticlesView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            listArticlesView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            listBlogsView.topAnchor.constraint(equalTo: listArticlesView.bottomAnchor, constant: 16),
            listBlogsView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            listBlogsView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            listReportsView.topAnchor.constraint(equalTo: listBlogsView.bottomAnchor, constant: 16),
            listReportsView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            listReportsView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            listReportsView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
}

