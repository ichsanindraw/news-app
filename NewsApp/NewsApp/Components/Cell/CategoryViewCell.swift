//
//  CategoryViewCell.swift
//  NewsApp
//
//  Created by Ichsan Indra Wahyudi on 27/09/24.
//

import Foundation
import UIKit
import Kingfisher

final class CategoryViewCell: UICollectionViewCell {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    static var cellReuseIdentifier: String {
        return String(describing: CategoryViewCell.self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        backgroundColor = .white
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = nil
        setSelected(false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        layer.borderWidth = 1
        layer.cornerRadius = 8
        
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    func configure(text: String) {
        titleLabel.text = text
    }
    
    func calculateSize(for text: String) -> CGSize {
        let maxLabelWidth: CGFloat = UIScreen.main.bounds.width - 32 
        let constraintRect = CGSize(width: maxLabelWidth, height: .greatestFiniteMagnitude)
        
        let boundingBox = text.boundingRect(
            with: constraintRect,
            options: .usesLineFragmentOrigin,
            attributes: [.font: titleLabel.font ?? UIFont.systemFont(ofSize: 17)],
            context: nil
        )
        
        return CGSize(width: boundingBox.width + 18, height: 40)
    }
    
    func setSelected(_ isSelected: Bool) {
        backgroundColor = isSelected ? .opaqueSeparator : .white
    }
}
