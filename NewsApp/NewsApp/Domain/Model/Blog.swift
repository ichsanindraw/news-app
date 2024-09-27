//
//  Blog.swift
//  NewsApp
//
//  Created by Ichsan Indra Wahyudi on 25/09/24.
//

import Foundation

struct Blog: Codable {
    let id: Int
    let title: String
    let url: String
    let imageURL: String
    let newsSite: String
    let summary: String
    let publishedAt: Date
    let updatedAt: String
    let featured: Bool

    enum CodingKeys: String, CodingKey {
        case id, title, url
        case imageURL = "image_url"
        case newsSite = "news_site"
        case summary
        case publishedAt = "published_at"
        case updatedAt = "updated_at"
        case featured
    }
}
