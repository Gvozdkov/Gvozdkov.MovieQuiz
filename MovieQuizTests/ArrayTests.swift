//
//  ArrayTests.swift
//  ArrayTests
//
//  Created by Алексей Гвоздков on 15.04.2023.

import XCTest
@testable import MovieQuiz

final class ArrayTests: XCTestCase {
    func testGetValueInRange() throws { // тест на успешное взятие элемента по индексу
        //Given
        let array = [1, 4, 2, 3, 5]
        
        //When
        let value = array[safe: 2]
        
        //Then
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 2)
    }
    
    func testGetValueOutOfRange() throws {
        //Given
        let array = [1, 4, 2, 3, 5]
        
        //When
        let value = array[safe: 20]
        
        //Then
        XCTAssertNil(value)
    }
    
    struct MoviesLoader: MoviesLoading {
        //MARK: - NetworkClient
        private let networkClient = NetworkClient()
        
        //MARK: - URL
        private var mostPopularMoviesUrl: URL {
            guard let url = URL(string: "https://imdb-api.com/en/API/Top250Movies/k_46pxiybd") else {
                preconditionFailure("Unable to construct mostPopularMoviesUrl")
            }
            return url
        }
        
        func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
            networkClient.fetch(url: mostPopularMoviesUrl) { result in
                switch result {
                case .success(let data):
                    do {
                        let mostPopularMovies = try JSONDecoder().decode(MostPopularMovies.self, from: data)
                        handler(.success(mostPopularMovies))
                    } catch {
                        handler(.failure(error))
                    }
                case .failure(let error):
                    handler(.failure(error))
                }
            }
        }
    }
}
