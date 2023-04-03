//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Алексей Гвоздков on 16.03.2023.
//

import UIKit

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer() // сообщение об успешной загрузке
    func didFailToLoadData(with error: Error) // сообщение об ошибке загрузки
}
