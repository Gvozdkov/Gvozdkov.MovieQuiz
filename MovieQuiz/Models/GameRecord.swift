//
//  GameRecord.swift
//  MovieQuiz
//
//  Created by Алексей Гвоздков on 24.03.2023.
//

import Foundation

struct GameRecord: Codable {
    let correct: Int
    let total: Int
    let date: Date
    
//    func isBetterThan(_ another: GameRecord) -> Bool {
//        correct > another.correct
}
