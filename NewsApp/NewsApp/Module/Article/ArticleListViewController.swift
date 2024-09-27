//
//  ArticleListViewController.swift
//  NewsApp
//
//  Created by Ichsan Indra Wahyudi on 26/09/24.
//

import Combine
import Kingfisher
import UIKit

final class ArticleListViewController: UIViewController, UIScrollViewDelegate, UISearchBarDelegate {
    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
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
    
    private var searchSubject = PassthroughSubject<String, Never>()
    private var searchSubjectCancellables = Set<AnyCancellable>()
    
    private let articleCollectionView = ArticleCollectionView()
    private let viewModel = ArticleViewModel()
    private var cancellables = Set<AnyCancellable>()
    
//    private var isLoadingMore: Bool = false
//    private var query: String = ""
//    private var offset: Int = 1
    private var lastContentOffset: CGFloat = 0
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Artikel"
        view.backgroundColor = .white
        
        searchBar.delegate = self
        scrollView.delegate = self
        
        bindViewModel()
        bindAction()
        setupUI()
        
        viewModel.getArticles()
    }
    
    private func bindViewModel() {
        viewModel.$viewState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                switch state {
                case.loading:
                    break
                case .error(_):
                    break
                case let .success(data):
                    self?.articleCollectionView.updateData(data)
                }
            }
            .store(in: &cancellables)
    }
    
    func bindAction() {
        searchSubject
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] searchText in
                print(">>> searchText: \(searchText)")
                self?.viewModel.searchArticles(query: searchText)
//                
//                if searchText.isEmpty {
//                    
////                    self?.viewModel.getArticles(limit: 10)
//                } else {
////                    self?.viewModel.getArticles(limit: 10, query: searchText)
//                }
            }
            .store(in: &searchSubjectCancellables)
    }
    
    private func setupUI() {
        view.addSubview(searchBar)
        view.addSubview(scrollView)
        
        scrollView.addSubview(wrapperView)
            
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: 50),
            
//            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            wrapperView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            wrapperView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            wrapperView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            wrapperView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            
            wrapperView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
       
        wrapperView.addSubview(articleCollectionView)
        
        NSLayoutConstraint.activate([
            articleCollectionView.topAnchor.constraint(equalTo: wrapperView.topAnchor),
            articleCollectionView.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor),
            articleCollectionView.trailingAnchor.constraint(equalTo: wrapperView.trailingAnchor),
            
            articleCollectionView.bottomAnchor.constraint(equalTo: wrapperView.bottomAnchor)
        ])
    }
    
//    private func loadMoreArticles() {
//        // prevent multiple requests
//        guard !isLoadingMore else { return }
//        
//        isLoadingMore = true
//        offset += 1
//        
//        // fetch more articles
//        viewModel.getArticles(limit: 10, offset: offset)
//    }
    
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
    
    // MARK: Protocols
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height - 50 {
            viewModel.loadMoreArticles()
        }
        
        // Detect scroll direction
        if offsetY > lastContentOffset {
            // User is scrolling down
//            hideSearchBar()
        } else if offsetY < lastContentOffset {
            // User is scrolling up
//            showSearchBar()
        }
        
        lastContentOffset = offsetY
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchSubject.send(searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

