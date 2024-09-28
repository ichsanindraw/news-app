//
//  NewsDetailViewController.swift
//  NewsApp
//
//  Created by Ichsan Indra Wahyudi on 26/09/24.
//

import Foundation
import Kingfisher
import UIKit

final class NewsDetailViewController: UIViewController {
    struct Data {
        let title: String
        let imageUrl: String
        let publishedAt: String
        let summary: String
    }
    
    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let wrapperView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    init(data: NewsDetailViewController.Data) {
        super.init(nibName: nil, bundle: nil)
        
        if let url = URL(string: data.imageUrl) {
            imageView.kf.setImage(with: url)
        } else {
            // set a placeholder image if URL is invalid
            imageView.image = UIImage(named: "placeholderImage")
        }
        
        titleLabel.text = data.title
        
        if let date = formatedDate(data.publishedAt) {
            dateLabel.text = date
        } else {
            dateLabel.text = data.publishedAt
        }
        
        contentLabel.text = "\(extractFirstSentence(from: data.summary))."
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        title = "Detail"
        
        setupUI()
    }
    
    func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(wrapperView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            wrapperView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            wrapperView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            wrapperView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            wrapperView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            
            wrapperView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        wrapperView.addSubview(imageView)
        wrapperView.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: wrapperView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: wrapperView.trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 200),
            
            containerView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            containerView.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: wrapperView.trailingAnchor, constant: -16),
        ])
       
        containerView.addSubview(titleLabel)
        containerView.addSubview(dateLabel)
        containerView.addSubview(contentLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            dateLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            contentLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 16),
            contentLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            contentLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            contentLabel.bottomAnchor.constraint(equalTo: wrapperView.bottomAnchor)
       ])
    }
}
