//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Алексей Гвоздков on 17.03.2023.
//

import UIKit

class AlertPresenter {
    
//    weak var viewController: UIViewController?
    
    func showAlert(in vs: UIViewController, model: AlertModel) {
        let alert = UIAlertController(title: model.title,
                                      message: model.message,
                                      preferredStyle:  .alert)
        
        let action = UIAlertAction(title: model.buttonText,
                                   style: .default) { _ in
            
            model.completion()
//            model.completion?()
        }
//        alert.view.accessibilityIdentifier = "Alert result"
//        alert.addAction(action)
//        viewController?.present(alert, animated: true)
        alert.addAction(action)
        vs.present(alert, animated: true, completion: nil)
    }
}

