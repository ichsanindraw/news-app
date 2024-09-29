//
//  RootViewController.swift
//  NewsApp
//
//  Created by Ichsan Indra Wahyudi on 26/09/24.
//

import Combine
import Foundation
import UIKit

struct NewsItem: Hashable {
    let id: String
    let title: String
    let imageUrl: String
    let publishedAt: String
    let summary: String
}

final class RootViewController: UIViewController {
    enum SectionType: Int, CaseIterable {
        case article
        case blog
        case report
        
        var title: String {
            switch self {
            case .article: return "Artikel"
            case .blog: return "Blog"
            case .report: return "Report"
            }
        }
    }
    
    private var dataSource: UICollectionViewDiffableDataSource<SectionType, NewsItem>!
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    private let collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        view.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.showsHorizontalScrollIndicator = false
        return view
    }()
    
    private var collectionViewHeightConstraint: NSLayoutConstraint?
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
        title = "News App"
        
        setupNavigationAppearance()
        setupNavigationBar()
        setupGreetings()
        setupCollection()
        setupUI()
        configureDataSource()
        bindViewModel()
        
        viewModel.getArticles(limit: 4)
        viewModel.getBlogs(limit: 4)
        viewModel.getReports(limit: 4)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        requestNotificationPermissions()
    }
    
    private func setupNavigationAppearance() {
        let appearance = UINavigationBarAppearance()
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    private func setupNavigationBar() {
        let rightBarButton = UIBarButtonItem(
            title: "Logout",
            style: .plain,
            target: self,
            action: #selector(rightBarButtonTapped)
        )
        
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
    private func setupGreetings() {
        let userData = UserManager.shared.getUserData()
        titleLabel.text = "\(getGreeting()), \(userData?.name ?? "")"
    }
    
    private func bindViewModel() {
        viewModel.$articlesViewState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleStateChange(for: state, section: .article)
            }
            .store(in: &cancellables)
        
        viewModel.$blogsViewState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleStateChange(for: state, section: .blog)
            }
            .store(in: &cancellables)
        
        viewModel.$reportsViewState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleStateChange(for: state, section: .report)
            }
            .store(in: &cancellables)
        
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { isLoading in
                if isLoading {
                    SwiftOverlays.showBlockingWaitOverlay()
                } else {
                    SwiftOverlays.removeAllBlockingOverlays()
                }
            }
            .store(in: &cancellables)
        
        viewModel.$errorMessage
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] message in
                self?.showErrorAlert(
                    title: "Authentication Failed",
                    message: message
                )
            }
            .store(in: &cancellables)
    }
    
    private func handleStateChange<T>(for state: ViewState<T>, section: SectionType) {
        guard case let .success(data) = state else { return }
        
        var snapshot = dataSource.snapshot()
        snapshot.appendSections([section])
        
        switch section {
        case .article:
            if let articles = data as? BaseResponse<[Article]> {
                let newItems = articles.results.enumerated().map { index, val -> NewsItem in
                    NewsItem(
                        id: "article-item-\(index)",
                        title: val.title,
                        imageUrl: val.imageUrl,
                        publishedAt: val.publishedAt,
                        summary: val.summary
                    )
                }
                
                snapshot.appendItems(newItems, toSection: section)
            }
          
        case .blog:
            if let articles = data as? BaseResponse<[Blog]> {
                let newItems = articles.results.enumerated().map { index, val -> NewsItem in
                    NewsItem(
                        id: "blog-item-\(index)",
                        title: val.title,
                        imageUrl: val.imageUrl,
                        publishedAt: val.publishedAt,
                        summary: val.summary
                    )
                }
                
                snapshot.appendItems(newItems, toSection: section)
            }
        case .report:
            if let articles = data as? BaseResponse<[Report]> {
                let newItems = articles.results.enumerated().map { index, val -> NewsItem in
                    NewsItem(
                        id: "report-item-\(index)",
                        title: val.title,
                        imageUrl: val.imageUrl,
                        publishedAt: val.publishedAt,
                        summary: val.summary
                    )
                }
                
                snapshot.appendItems(newItems, toSection: section)
            }
        }
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func setupCollection() {
        collectionView.delegate = self
        
        collectionView.register(
            ThumbnailViewCell.self,
            forCellWithReuseIdentifier: ThumbnailViewCell.cellReuseIdentifier
        )
        
        collectionView.register(
            HeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: HeaderView.cellReuseIdentifier
        )
        
        collectionView.setCollectionViewLayout(createSectionLayout(), animated: true)
    }
    
    private func createSectionLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, _ in
            guard SectionType(rawValue: sectionIndex) != nil else { return nil }
            
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(1.0)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 16)
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.6),
                heightDimension: .absolute(200)
            )
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(40)
            )
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            
            let sectionLayout = NSCollectionLayoutSection(group: group)
            sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 0)
            sectionLayout.orthogonalScrollingBehavior = .continuous
            sectionLayout.boundarySupplementaryItems = [sectionHeader]
            
            return sectionLayout
        }
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<SectionType, NewsItem>(collectionView: collectionView) { collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ThumbnailViewCell.cellReuseIdentifier, for: indexPath) as? ThumbnailViewCell else {
                return UICollectionViewCell()
            }
            
            let contentItem = ThumbnailViewCell.Data(title: item.title, imageUrl: item.imageUrl)
            cell.configure(data: contentItem)
            return cell
        }
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader,
                  let section = SectionType(rawValue: indexPath.section),
                  let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: UICollectionView.elementKindSectionHeader,
                    withReuseIdentifier: HeaderView.cellReuseIdentifier,
                    for: indexPath) as? HeaderView
            else {
                return nil
            }
            
            header.configure(title: section.title, onSeeMoreTapped: { [weak self] in
                // Handle 'See More' action
                let viewController: UIViewController
                
                switch section {
                case .article: viewController = ArticleViewController()
                case .blog: viewController = BlogViewController()
                case .report: viewController = ReportViewController()
                }
                
                self?.navigationController?.pushViewController(viewController, animated: true)
            })
            
            return header
        }
    }
    
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(collectionView)
       
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc func rightBarButtonTapped() {
        let alert = UIAlertController(
            title: "Logout Confirmation",
            message: "Are you sure you want to log out? You will need to log in again to access your account.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Oke", style: .destructive, handler: { [weak self] _ in
            self?.viewModel.logout()
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    private func showErrorAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension RootViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let section = SectionType(rawValue: indexPath.section)!
        
        var content: NewsDetailViewController.Data?
        
        switch section {
        case .article:
            if case let .success(data) = viewModel.articlesViewState {
                let item = data[indexPath.row]
                content = NewsDetailViewController.Data(
                    title: item.title,
                    imageUrl: item.imageUrl,
                    publishedAt: item.publishedAt,
                    summary: item.summary
                )
            }
        case .blog:
            if case let .success(data) = viewModel.blogsViewState {
                let item = data[indexPath.row]
                content = NewsDetailViewController.Data(
                    title: item.title,
                    imageUrl: item.imageUrl,
                    publishedAt: item.publishedAt,
                    summary: item.summary
                )
            }
        case .report:
            if case let .success(data) = viewModel.reportsViewState {
                let item = data[indexPath.row]
                content = NewsDetailViewController.Data(
                    title: item.title,
                    imageUrl: item.imageUrl,
                    publishedAt: item.publishedAt,
                    summary: item.summary
                )
            }
        }
        
        if let content = content {
            let viewController = NewsDetailViewController(data: content)
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
}
