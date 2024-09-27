//
//  HeaderView.swift
//  NewsApp
//
//  Created by Ichsan Indra Wahyudi on 27/09/24.
//

import Foundation
import UIKit

final class HeaderView: UICollectionReusableView {
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
    
    static let cellReuseIdentifier = String(describing: HeaderView.self)
    private var onSeeMoreTapped: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        seeMoreLabel.addTarget(self, action: #selector(seeMoreTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(titleLabel)
        addSubview(seeMoreLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            seeMoreLabel.topAnchor.constraint(equalTo: topAnchor),
            seeMoreLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            seeMoreLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
       ])
    }
    
    @objc private func seeMoreTapped() {
        onSeeMoreTapped?()
    }
    
    func configure(title: String, onSeeMoreTapped: @escaping () -> Void) {
        titleLabel.text = title
        self.onSeeMoreTapped = onSeeMoreTapped
    }
}
