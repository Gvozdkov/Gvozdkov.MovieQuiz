//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Алексей Гвоздков on 22.04.2023.
//

//import Foundation
//import UIKit
//
//final class MovieQuizPresenter {
//    var currentQuestion: QuizQuestion?
//    var currentQuestionIndex: Int = 0
//    let questionsAmount: Int =  10
//    var correctAnswers: Int = 0
//    
//    var questionFactory: QuestionFactoryProtocol?
//    weak var viewController: MovieQuizViewController?
//    
//    func convert(model: QuizQuestion) -> QuizStepViewModel {    // тут конвертируем информацию для экрана в состояние "Вопрос задан"
//        return QuizStepViewModel(
//            image: UIImage(data: model.image) ?? UIImage(),
//            question: model.text,
//            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
//    }
//    
//    private func didAnswerClicked(isYes: Bool) {
//        guard let currentQuestion = currentQuestion else {
//            return
//        }
//        let givanAnswer = isYes
//        viewController?.showAnswerResult(isCorrect: givanAnswer == currentQuestion.correctAnswer)
//    }
//    
//    func didReceiveNextQuestion(question: QuizQuestion?) {
//        guard let question = question else {
//            return
//        }
//        
//        currentQuestion = question
//        let viewModel = convert(model: question)
//        
//        DispatchQueue.main.async { [weak self] in
//            self?.viewController?.show(quiz: viewModel)
//        }
//    }
//    
//    func showNextQuestionOrResults() {
//        viewController?.blockButton()
//        
//        if currentQuestionIndex == questionsAmount - 1 {
//            let text = "Вы ответили на \(correctAnswers) из 10, попробуйте еще раз!"
//            
//            let viewModel = QuizResultsViewModel(
//               title: "Этот раунд окончен!",
//               text: text,
//               buttonText: "Сыграть ещё раз")
//               viewController?.show(quiz: viewModel)
//        } else {
//            currentQuestionIndex += 1
//            questionFactory?.requestNextQuestion()
//        }
//    }
//    // MARK: - Button
//    
//    func yesButtonClicked() {
//        didAnswerClicked(isYes: true)
//    }
//    
//    func noButtonClicked() {
//        didAnswerClicked(isYes: false)
//    }
//    
//}

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    var currentQuestionIndex: Int = 0
    let questionsAmount: Int =  10
    var correctAnswers: Int = 0
    
    var currentQuestion: QuizQuestion?
    var questionFactory: QuestionFactoryProtocol?
    weak var viewController: MovieQuizViewController?
    //MARK: - QuestionFactoryDelegate
    
    func didLoadDataFromServer() {
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        viewController?.showNetworkError(message: error.localizedDescription)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
            guard let question = question else {
                return
            }
            
            currentQuestion = question
            let viewModel = convert(model: question)
            
            DispatchQueue.main.async { [weak self] in
                self?.viewController?.show(quiz: viewModel)
            }
        }
    //MARK: - Methods
    func showNextQuestionOrResults() {
            viewController?.blockButton()
            
            if currentQuestionIndex == questionsAmount - 1 {
                let text = "Вы ответили на \(correctAnswers) из 10, попробуйте еще раз!"
                
                let viewModel = QuizResultsViewModel(
                   title: "Этот раунд окончен!",
                   text: text,
                   buttonText: "Сыграть ещё раз")
                   viewController?.show(quiz: viewModel)
            } else {
                currentQuestionIndex += 1
                questionFactory?.requestNextQuestion()
            }
        }

        

        func convert(model: QuizQuestion) -> QuizStepViewModel {    // тут конвертируем информацию для экрана в состояние "Вопрос задан"
                return QuizStepViewModel(
                    image: UIImage(data: model.image) ?? UIImage(),
                    question: model.text,
                    questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
            }

        func didAnswerClicked(isYes: Bool) {
                guard let currentQuestion = currentQuestion else {
                    return
                }
                let givanAnswer = isYes
                viewController?.showAnswerResult(isCorrect: givanAnswer == currentQuestion.correctAnswer)
            }

        
        
        func yesButtonClicked() {
            didAnswerClicked(isYes: true)
        }
        
        func noButtonClicked() {
            didAnswerClicked(isYes: false)
        }

        
    }
    
