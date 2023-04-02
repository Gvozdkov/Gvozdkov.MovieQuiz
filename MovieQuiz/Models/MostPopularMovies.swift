//
//  MostPopularMovies.swift
//  MovieQuiz
//
//  Created by Алексей Гвоздков on 02.04.2023.
//

import Foundation

struct MostPopularMovies: Codable {
    let errorMassage: String
    let items: [MostPopularMovies]
}

struct MostPopularMovie: Codable {
    let title: String
    let rating: String
    let imageURL: URL
}

private enum CodingKeys: String, Codable {
    case title = "fullTitle"
    case rating = "imDbrating"
    case imageURL = "image"
}
