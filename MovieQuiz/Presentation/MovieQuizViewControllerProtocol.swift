//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Алексей Гвоздков on 24.04.2023.
//

import Foundation

import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func showNetworkError(message: String)
    
    func blockButtons(onOf: Bool)
}