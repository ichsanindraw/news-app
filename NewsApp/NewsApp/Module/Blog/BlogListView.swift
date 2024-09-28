//
//  BlogListView.swift
//  NewsApp
//
//  Created by Ichsan Indra Wahyudi on 28/09/24.
//

import Foundation
import UIKit

final class BlogListView: UIView {
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        layout.scrollDirection = .vertical
        
        let view = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        
        view.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.showsHorizontalScrollIndicator = false
        view.isScrollEnabled = false
        return view
    }()
    
    private var data: [Blog] = [] {
       didSet {
           collectionView.reloadData()
           updateCollectionViewHeight()
       }
    }
    
    private var collectionViewHeightConstraint: NSLayoutConstraint?
    
    init() {
        super.init(frame: .zero)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        setupCollection()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        // set the initial height constraint for the collectionView
        collectionViewHeightConstraint = collectionView.heightAnchor.constraint(equalToConstant: 0)
        collectionViewHeightConstraint?.isActive = true
    }
    
    private func setupCollection() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(
            ThumbnailViewCell.self,
            forCellWithReuseIdentifier: ThumbnailViewCell.cellReuseIdentifier
        )
    }
    
    private func updateCollectionViewHeight() {
        collectionView.layoutIfNeeded()
        
        let contentHeight = collectionView.contentSize.height
        collectionViewHeightConstraint?.constant = contentHeight
   }
    
    func updateData(_ newData: [Blog]) {
        self.data = newData
    }
}

extension BlogListView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ThumbnailViewCell.cellReuseIdentifier, for: indexPath) as? ThumbnailViewCell else {
            return UICollectionViewCell()
        }
        
        let item = data[indexPath.row]
        let data = ThumbnailViewCell.Data(
            title: item.title,
            imageUrl: item.imageUrl
        )
        
        cell.configure(data: data)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let item = data[indexPath.row]
        let data = NewsDetailViewController.Data(
            title: item.title,
            imageUrl: item.imageUrl,
            publishedAt: item.publishedAt,
            summary: item.summary
        )
        
        let viewController = NewsDetailViewController(data: data)
        
        self.closestViewController?.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width - 16
        return CGSize(width: width - 16, height: 200)
    }
}
