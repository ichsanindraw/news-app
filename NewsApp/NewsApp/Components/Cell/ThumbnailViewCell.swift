//
//  ThumbnailViewCell.swift
//  NewsApp
//
//  Created by Ichsan Indra Wahyudi on 26/09/24.
//

import Foundation
import Kingfisher
import UIKit

final class ThumbnailViewCell: UICollectionViewCell {
    struct Data {
        let title: String
        let imageUrl: String
        let launches: [String] = []
        let events: [String] = []
    }
    
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
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
    
    private let launchLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let eventLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
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
        
        // Remove launchLabel to avoid showing stale data
        if stackView.subviews.contains(launchLabel) {
            stackView.removeArrangedSubview(launchLabel)
        }
        
        if stackView.subviews.contains(eventLabel) {
            stackView.removeArrangedSubview(eventLabel)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(titleLabel)
        
        imageView.heightAnchor.constraint(lessThanOrEqualToConstant: 200).isActive = true
        
        // Prevent the title from being compressed
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
    }
    
    func configure(data: ThumbnailViewCell.Data) {
        let launches = data.launches
        let events = data.events
        
        let secureImageUrl = data.imageUrl.replacingOccurrences(of: "http://", with: "https://")
        
        if !secureImageUrl.isEmpty, let url = URL(string: secureImageUrl) {
            imageView.kf.setImage(with: url)
        } else if let url = URL(string: "https://placehold.co/600x400?font=roboto&text=Image\nNot\nFound") {
            imageView.kf.setImage(with: url)
        } else {
            // set a placeholder image if URL is invalid
            imageView.image = UIImage(named: "placeholderImage")
        }
        
        titleLabel.text = data.title
        
        if !launches.isEmpty, !stackView.subviews.contains(launchLabel) {
            stackView.addArrangedSubview(launchLabel)
            launchLabel.text = "Launches: \(launches.map { $0 }.joined(separator: ","))"
        }
        
        if !events.isEmpty, !stackView.subviews.contains(eventLabel) {
            stackView.addArrangedSubview(eventLabel)
            eventLabel.text = "Events: \(launches.map { $0 }.joined(separator: ","))"
        }
    }
}
