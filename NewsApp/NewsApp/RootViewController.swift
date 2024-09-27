//
//  RootViewController.swift
//  NewsApp
//
//  Created by Ichsan Indra Wahyudi on 26/09/24.
//

import Combine
import Foundation
import UIKit

final class RootViewController: UIViewController {
    enum SectionType: Int, CaseIterable {
        case article
        case blog
        case report
    }
    
    private let collectionView: UICollectionView = {
        let view = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        
        view.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
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
        
        setupNavigationTitle()
        setupNavigationAppearance()
        setupCollection()
        setupUI()
        
        bindViewModel()
        
        viewModel.getArticles(limit: 4)
//        viewModel.getBlogs(limit: 4)
//        viewModel.getReports(limit: 4)
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
        viewModel.$articlesViewState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                switch state {
                case let .success(data):
                    print(">>> handleStateChange $articlesViewState: \(data.results.count)")
                    self?.handleStateChange(
                        for: state,
                        section: SectionType.article.rawValue
                    )
                default:
                    break
                }
            }
            .store(in: &cancellables)
        
        viewModel.$blogsViewState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                switch state {
                case let .success(data):
                    print(">>> handleStateChange $blogsViewState: \(data.results.count)")
                    self?.handleStateChange(
                        for: state,
                        section: SectionType.blog.rawValue
                    )
                default:
                    break
                }
            }
            .store(in: &cancellables)
        
        viewModel.$reportsViewState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                switch state {
                case let .success(data):
                    print(">>> handleStateChange $reportsViewState: \(data.results.count)")
                    self?.handleStateChange(
                        for: state,
                        section: SectionType.report.rawValue
                    )
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }
    
    private func handleStateChange<T>(for state: ViewState<T>, section: Int) {
        DispatchQueue.main.async {
            self.collectionView.performBatchUpdates({
               self.collectionView.reloadSections(IndexSet(integer: section))
           }, completion: nil)
        }
    }
    
//    private func handleStateChange<T>(for state: ViewState<T>, section: Int) {
//        DispatchQueue.main.async {
//            switch section {
//            case SectionType.article.rawValue:
//                if case .success(let data) = self.viewModel.articlesViewState, !data.results.isEmpty {
//                    self.collectionView.performBatchUpdates({
//                        self.collectionView.reloadSections(IndexSet(integer: section))
//                    }, completion: nil)
//                }
//            case SectionType.blog.rawValue:
//                if case .success(let data) = self.viewModel.blogsViewState, !data.results.isEmpty {
//                    self.collectionView.performBatchUpdates({
//                        self.collectionView.reloadSections(IndexSet(integer: section))
//                    }, completion: nil)
//                }
//            case SectionType.report.rawValue:
//                if case .success(let data) = self.viewModel.reportsViewState, !data.results.isEmpty {
//                    self.collectionView.performBatchUpdates({
//                        self.collectionView.reloadSections(IndexSet(integer: section))
//                    }, completion: nil)
//                }
//            default:
//                break
//            }
//        }
//    }

    
    private func setupCollection() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(
            ThumbnailViewCell.self,
            forCellWithReuseIdentifier: ThumbnailViewCell.cellReuseIdentifier
        )
        
        collectionView.register(
            HeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: HeaderView.cellReuseIdentifier
        )
        
        collectionView.register(
            UICollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "DefaultSupplementaryView"
        )
        
        collectionView.setCollectionViewLayout(createSectionLayout(), animated: true)
    }
    
    private func createSectionLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { _, _ in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(1.0)
            )
            
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(
                top: 0,
                leading: 8,
                bottom: 0,
                trailing: 8
            )
                  
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.6),
                heightDimension: .absolute(200)
            )
            
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitems: [item]
            )
            
            // Add header to each section
            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(40)
            )
            
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
                  
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(
                top: 8,
                leading: 8,
                bottom: 8,
                trailing: 8
            )
            section.orthogonalScrollingBehavior = .continuous
            section.boundarySupplementaryItems = [sectionHeader]
            
            return section
        }
    }
    
    private func setupUI() {
        view.addSubview(collectionView)
       
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

}

extension RootViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return SectionType.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionType = SectionType(rawValue: section)
        
        switch sectionType {
        case .article:
            if case let .success(data) = viewModel.articlesViewState {
                print(">>> articlesViewState: \(data.results.count)")
                return data.results.count
            }
            
        case .blog:
            if case let .success(data) = viewModel.blogsViewState {
                print(">>> blogsViewState: \(data.results.count)")
                return data.results.count
            }
            
        case .report:
            if case let .success(data) = viewModel.reportsViewState {
                print(">>> reportsViewState: \(data.results.count)")
                return data.results.count
            }
            
        default:
            return 0
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ThumbnailViewCell.cellReuseIdentifier, for: indexPath) as? ThumbnailViewCell else {
            return UICollectionViewCell()
        }
        
        print(">>>  indexPath \(indexPath)")
        
        let sectionType = SectionType(rawValue: indexPath.section)
        
        switch sectionType {
        case .article:
            if case let .success(data) = viewModel.articlesViewState {
                let item = data.results[indexPath.item]
                let contentItem = ThumbnailViewCell.Data(
                    title: item.title,
                    imageUrl: item.imageUrl
                )
                
                cell.configure(data: contentItem)
            }
            
        case .blog:
            if case let .success(data) = viewModel.blogsViewState {
                let item = data.results[indexPath.item]
                let contentItem = ThumbnailViewCell.Data(
                    title: item.title,
                    imageUrl: item.imageUrl
                )
                
                cell.configure(data: contentItem)
            }
            
        case .report:
            if case let .success(data) = viewModel.reportsViewState {
                let item = data.results[indexPath.item]
                let contentItem = ThumbnailViewCell.Data(
                    title: item.title,
                    imageUrl: item.imageUrl
                )
                
                cell.configure(data: contentItem)
            }
            
        default: break
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader, let cell = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderView.cellReuseIdentifier, for: indexPath) as? HeaderView else {
            return UICollectionReusableView()
        }
        
        let sectionType = SectionType(rawValue: indexPath.section)
        
        switch sectionType {
        case .article:
            cell.configure(title: "Artikel", onSeeMoreTapped: { [weak self] in
                let viewController = ArticleListViewController()
                self?.navigationController?.pushViewController(viewController, animated: true)
            })
            
        case .blog:
            cell.configure(title: "Blog", onSeeMoreTapped: {
                
            })
            
        case .report:
            cell.configure(title: "Report", onSeeMoreTapped: {
                
            })
            
        default:  break
        }
        
        return cell
    }
}

extension RootViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let sectionType = SectionType(rawValue: indexPath.section)
        
        var content: NewsDetailViewController.Data?
        
        switch sectionType {
        case .article:
            if case let .success(data) = viewModel.articlesViewState {
                let item = data.results[indexPath.row]
                
                content = NewsDetailViewController.Data(
                    title: item.title,
                    imageUrl: item.imageUrl,
                    publishedAt: item.publishedAt,
                    summary: item.summary
                )
            }
            
        case .blog:
            if case let .success(data) = viewModel.blogsViewState {
                let item = data.results[indexPath.row]
                
                content = NewsDetailViewController.Data(
                    title: item.title,
                    imageUrl: item.imageUrl,
                    publishedAt: item.publishedAt,
                    summary: item.summary
                )
            }
            
        case .report:
            if case let .success(data) = viewModel.reportsViewState {
                let item = data.results[indexPath.row]
                
                content = NewsDetailViewController.Data(
                    title: item.title,
                    imageUrl: item.imageUrl,
                    publishedAt: item.publishedAt,
                    summary: item.summary
                )
            }
            
        default: break
        }
        
        if let content {
            let viewController = NewsDetailViewController(data: content)

            navigationController?.pushViewController(viewController, animated: true)
        }
    }
}
