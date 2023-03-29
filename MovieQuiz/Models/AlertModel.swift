//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Алексей Гвоздков on 29.03.2023.
//

import UIKit
// Для алерта с результатом квиза
struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: (() -> Void)?
}
