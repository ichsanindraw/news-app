//
//  ThumbnailViewCell.swift
//  NewsApp
//
//  Created by Ichsan Indra Wahyudi on 26/09/24.
//

import Foundation
import UIKit
import Kingfisher

final class ThumbnailViewCell: UICollectionViewCell {
    struct Data {
        let title: String
        let imageUrl: String
        let launches: [String] = []
        let events: [String] = []
    }
    
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = 8
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let launcheLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.text = "Launches"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    static var cellReuseIdentifier: String {
        return String(describing: ThumbnailViewCell.self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
        titleLabel.text = nil
        
        launcheLabel.removeFromSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
//        backgroundColor = .blue
        
        addSubview(imageView)
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
           imageView.topAnchor.constraint(equalTo: topAnchor),
           imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
           imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
           
           titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
           titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
           titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
           titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
       ])
    }
    
    func configure(data: ThumbnailViewCell.Data) {
        if let url = URL(string: data.imageUrl) {
            imageView.kf.setImage(with: url)
        } else {
            // set a placeholder image if URL is invalid
            imageView.image = UIImage(named: "placeholderImage")
        }
        
        titleLabel.text = data.title
        
        if !data.launches.isEmpty {
            addSubview(launcheLabel)
            
            NSLayoutConstraint.activate([
                launcheLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
                launcheLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
                launcheLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            ])
        }
    }
}
