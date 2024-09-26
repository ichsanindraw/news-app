//
//  HorizontalListView.swift
//  NewsApp
//
//  Created by Ichsan Indra Wahyudi on 26/09/24.
//

import UIKit

final class HorizontalListView<D: BaseContent>: UIView, UICollectionViewDataSource, UICollectionViewDelegate {
    private let headerContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        return label
    }()
    
    private let seeMoreLabel: UIButton = {
        let label = UIButton()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setTitle("See More", for: .normal)
        label.setTitleColor(.black, for: .normal)
        label.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 200, height: 200)
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        layout.scrollDirection = .horizontal
        
        let view = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        
        view.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.showsHorizontalScrollIndicator = false
        return view
    }()
    
    private var data: [D] = [] {
       didSet {
           collectionView.reloadData()
       }
    }
    
    init(title: String) {
        super.init(frame: .zero)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.text = title
        
        setupUI()
        setupCollection()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(headerContainerView)
        addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            headerContainerView.topAnchor.constraint(equalTo: topAnchor),
            headerContainerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            headerContainerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            collectionView.topAnchor.constraint(equalTo: headerContainerView.bottomAnchor, constant: 8),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 200),
        ])
        
        headerContainerView.addSubview(titleLabel)
        headerContainerView.addSubview(seeMoreLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: headerContainerView.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: headerContainerView.bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: headerContainerView.leadingAnchor),
            
            seeMoreLabel.topAnchor.constraint(equalTo: headerContainerView.topAnchor),
            seeMoreLabel.bottomAnchor.constraint(equalTo: headerContainerView.bottomAnchor),
            seeMoreLabel.trailingAnchor.constraint(equalTo: headerContainerView.trailingAnchor)
        ])
    }
    
    private func setupCollection() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(
            ThumbnailViewCell<D>.self,
            forCellWithReuseIdentifier: ThumbnailViewCell<D>.cellReuseIdentifier
        )
    }
    
    func updateData(_ newData: [D]) {
        self.data = newData
    }
    
    // MARK: Protocols
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ThumbnailViewCell<D>.cellReuseIdentifier, for: indexPath) as? ThumbnailViewCell<D> else {
            return UICollectionViewCell()
        }
        
        cell.configure(data: data[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let viewController = NewsDetailViewController(data: data[indexPath.row])
        
        self.closestViewController?.navigationController?.pushViewController(viewController, animated: true)
    }
}

