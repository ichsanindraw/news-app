//
//  CategoryListView.swift
//  NewsApp
//
//  Created by Ichsan Indra Wahyudi on 27/09/24.
//

import Combine
import UIKit

final class CategoryListView: UIView {
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
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
    
    private var data: [String] = [] {
       didSet {
           collectionView.reloadData()
       }
    }
    
    private var selectedIndexPath: IndexPath?
    
    var selectedCategory = PassthroughSubject<String, Never>()
    
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
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func setupCollection() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(
            CategoryViewCell.self,
            forCellWithReuseIdentifier: CategoryViewCell.cellReuseIdentifier
        )
    }
    
    func updateData(_ newData: [String]) {
        self.data = newData
    }
}


extension CategoryListView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryViewCell.cellReuseIdentifier, for: indexPath) as? CategoryViewCell else {
            return UICollectionViewCell()
        }
        
        cell.configure(text: data[indexPath.row])
        
        // Update cell appearance based on selection state
        cell.setSelected(indexPath == selectedIndexPath)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let text = data[indexPath.row]
        
        // Assuming the cell can calculate the size based on its content
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryViewCell.cellReuseIdentifier, for: indexPath) as? CategoryViewCell else {
            return CGSize(width: 40, height: 40)
        }
        
        // Get size based on the text content
        return cell.calculateSize(for: text)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedText = data[indexPath.row]
        
        // If the user taps the already selected item, deselect it
        if selectedIndexPath == indexPath {
            // Deselect the cell
            if let selectedCell = collectionView.cellForItem(at: indexPath) as? CategoryViewCell {
                selectedCell.setSelected(false)
            }
            
            // Clear the selectedIndexPath
            selectedIndexPath = nil
            
            // Send an empty string or nil to indicate deselection (optional)
            selectedCategory.send("")
        } else {
            // Deselect the previously selected cell
            if let previousIndexPath = selectedIndexPath, let previousCell = collectionView.cellForItem(at: previousIndexPath) as? CategoryViewCell {
                previousCell.setSelected(false)
            }
            
            // Select the new cell
            if let selectedCell = collectionView.cellForItem(at: indexPath) as? CategoryViewCell {
                selectedCell.setSelected(true)
            }
            
            // Update the selectedIndexPath to the current one
            selectedIndexPath = indexPath
            
            // Publish the selected category
            selectedCategory.send(selectedText)
        }
    }
}
