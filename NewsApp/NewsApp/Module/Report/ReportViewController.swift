//
//  ReportViewController.swift
//  NewsApp
//
//  Created by Ichsan Indra Wahyudi on 28/09/24.
//

import Combine
import Kingfisher
import UIKit

final class ReportViewController: UIViewController {
    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let wrapperView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let searchBar: UISearchBar = {
       let searchBar = UISearchBar()
       searchBar.translatesAutoresizingMaskIntoConstraints = false
       return searchBar
   }()
    
    private let recentSearchView: RecentSearchView = {
        let view = RecentSearchView()
        view.isHidden = true
        return view
    }()
    
    private var searchSubject = PassthroughSubject<String, Never>()
    private var searchSubjectCancellables = Set<AnyCancellable>()
    
    private let reportListView = ReportListView()
    private let categoryListView = CategoryListView()
    private let viewModel = ReportViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Report"
        view.backgroundColor = .white
        
        searchBar.delegate = self
        scrollView.delegate = self
        
        bindViewModel()
        bindAction()
        setupUI()
        
        viewModel.getReports()
        viewModel.getCategories()
    }
    
    private func bindViewModel() {
        viewModel.$reportsViewState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                switch state {
                case.loading:
                    break
                case .error(_):
                    break
                case let .success(data):
                    self?.reportListView.updateData(data)
                }
            }
            .store(in: &cancellables)
        
        viewModel.$categoryViewState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                switch state {
                case.loading:
                    break
                case .error(_):
                    break
                case let .success(data):
                    self?.categoryListView.updateData(data)
                }
            }
            .store(in: &cancellables)
        
        viewModel.$recentSearch
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                self?.recentSearchView.updateData(data)
            }
            .store(in: &cancellables)
        
        recentSearchView.selectedTextSubject
            .sink {  [weak self] recentSearch in
                self?.viewModel.searchArticles(query: recentSearch)
                self?.searchBar.text = recentSearch
                self?.searchBar.resignFirstResponder()
            }
            .store(in: &cancellables)
        
        categoryListView.selectedCategory
            .sink {  [weak self] category in
                self?.viewModel.filterBy(category: category)
            }
            .store(in: &cancellables)
        
    }
    
    func bindAction() {
        searchSubject
            .debounce(for: .milliseconds(650), scheduler: RunLoop.main)
            .sink { [weak self] searchText in
                self?.viewModel.searchArticles(query: searchText)
            }
            .store(in: &searchSubjectCancellables)
    }
    
    private func setupUI() {
        view.addSubview(searchBar)
        view.addSubview(recentSearchView)
        view.addSubview(categoryListView)
        view.addSubview(scrollView)
        
        view.bringSubviewToFront(recentSearchView)
        
        scrollView.addSubview(wrapperView)
            
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: 50),
            
            recentSearchView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            recentSearchView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            recentSearchView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            recentSearchView.heightAnchor.constraint(equalToConstant: 150),

            categoryListView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            categoryListView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            categoryListView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            scrollView.topAnchor.constraint(equalTo: categoryListView.bottomAnchor, constant: 8),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            wrapperView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            wrapperView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            wrapperView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            wrapperView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            
            wrapperView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        wrapperView.addSubview(reportListView)
        
        NSLayoutConstraint.activate([
            reportListView.topAnchor.constraint(equalTo: wrapperView.topAnchor),
            reportListView.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor),
            reportListView.trailingAnchor.constraint(equalTo: wrapperView.trailingAnchor),
            
            reportListView.bottomAnchor.constraint(equalTo: wrapperView.bottomAnchor)
        ])
    }
    
    private func hideSearchBar() {
        UIView.animate(withDuration: 0.3, animations: {
            self.searchBar.transform = CGAffineTransform(translationX: 0, y: -self.searchBar.bounds.height)
        })
    }
    
    private func showSearchBar() {
        UIView.animate(withDuration: 0.3, animations: {
            self.searchBar.transform = .identity
        })
    }
}

extension ReportViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height - 50 {
            viewModel.loadMoreArticles()
        }
    }
}

extension ReportViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        recentSearchView.isHidden = true
        searchSubject.send(searchText)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        let recentSearch = viewModel.getRecentSearches()
        
        if !recentSearch.isEmpty {
            recentSearchView.isHidden = false
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        recentSearchView.isHidden = true
    }
}

