//
//  RecentSearchView.swift
//  NewsApp
//
//  Created by Ichsan Indra Wahyudi on 27/09/24.
//

import Combine
import UIKit

final class RecentSearchView: UIView {
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.sectionHeaderTopPadding = 0
        return tableView
    }()
    
    private var data: [String] = [] {
       didSet {
           tableView.reloadData()
       }
    }
    
    private let viewModel = ArticleViewModel()
    var selectedTextSubject = PassthroughSubject<String, Never>()
    
    init() {
        super.init(frame: .zero)
        
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .red
        
        setupTable()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupTable() {
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: "RecentSearchCell"
        )
    }
    
    private func setupUI() {
        addSubview(tableView)
        
        // Setup constraints for recent search table view
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func updateData(_ newData: [String]) {
        self.data = newData
    }
}

extension RecentSearchView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecentSearchCell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        cell.separatorInset = UIEdgeInsets.zero
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedTextSubject.send(data[indexPath.row])
    }
}
