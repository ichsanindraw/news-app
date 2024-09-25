//
//  Article.swift
//  NewsApp
//
//  Created by Ichsan Indra Wahyudi on 25/09/24.
//

import Foundation

struct BaseResponse<T: Decodable & Equatable>: Decodable, Equatable {
    let count: Int
    let next: String?
    let previous: String?
    let results: T?
}

protocol BaseContent: Codable, Equatable {
    var id: Int { get }
    var title: String { get }
    var url: String { get }
    var imageUrl: String { get }
    var newsSite: String { get }
    var summary: String { get }
    var publishedAt: String { get }
    var updatedAt: String { get }
}

protocol AdditionalContent: Codable, Equatable {
    var featured: Bool { get }
    var launches: [Launch] { get }
    var events: [Event] { get }
}

struct Report: BaseContent {
    let id: Int
    let title: String
    let url: String
    let imageUrl: String
    let newsSite: String
    let summary: String
    let publishedAt: String
    let updatedAt: String
}

struct Article: BaseContent, AdditionalContent {
    let id: Int
    let title: String
    let url: String
    let imageUrl: String
    let newsSite: String
    let summary: String
    let publishedAt: String
    let updatedAt: String
    let featured: Bool
    let launches: [Launch]
    let events: [Event]
}

struct Blog: BaseContent, AdditionalContent {
    let id: Int
    let title: String
    let url: String
    let imageUrl: String
    let newsSite: String
    let summary: String
    let publishedAt: String
    let updatedAt: String
    let featured: Bool
    let launches: [Launch]
    let events: [Event]
}

struct Launch: Codable, Equatable {
    let launchId: String
    let provider: String
}

struct Event: Codable, Equatable {
    let eventId: String
    let provider: String
}

// Helper

enum ViewState<T: Equatable>: Equatable {
    case loading
    case success(T)
    case error(String)
}
