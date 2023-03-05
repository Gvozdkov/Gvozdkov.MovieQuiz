import UIKit

final class MovieQuizViewController: UIViewController {
    // MARK: - Lifecycle
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    
    @IBOutlet private var nuButton: UIButton!
    @IBOutlet private var yesButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = UIImage(named: "The Godfather") // - так view заполняется и мы видем постер
//        show(quiz: QuizStepViewModel) - но когда использую метод, то ни чего не выходит... не исключаю, что метод написан не правильно...
    }
    


    // для состояния "Вопрос задан"
    private struct QuizStepViewModel {
      let image: UIImage
      let question: String
      let questionNumber: String
    }

    // для состояния "Результат квиза"
    private struct QuizResultsViewModel {
      let title: String
      let text: String
      let buttonText: String
    }
    
    private struct QuizQuestion {
      let image: String
      let text: String
      let correctAnswer: Bool
    }

    private let questions: [QuizQuestion] = [
            QuizQuestion(
                image: "The Godfather",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "The Dark Knight",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "Kill Bill",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "The Avengers",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "Deadpool",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "The Green Knight",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "Old",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: false),
            QuizQuestion(
                image: "The Ice Age Adventures of Buck Wild",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: false),
            QuizQuestion(
                image: "Tesla",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: false),
            QuizQuestion(
                image: "Vivarium",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: false)
        ]

    @IBAction private func noButtonClicked(_ sender: Any) {
    }
    
    @IBAction private func yesButtonClickd(_ sender: Any) {
    }
    

    private var currentQuestionIndex: Int = 0
    
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
    return QuizStepViewModel(
        image: UIImage(named: model.image) ?? UIImage(),
        question: model.text,
        questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)")
      }
    
    private func show(quiz step: QuizStepViewModel) {
//        imageView.image = UIImage(named: "\(step.image)") - пробовал так написать, но увы, что-то пошло не так ((
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        
        // здесь мы заполняем нашу картинку, текст и счётчик данными
    }

    private func show(quiz result: QuizResultsViewModel) {
        let currentQuestion = questions[currentQuestionIndex]
      // здесь мы показываем результат прохождения квиза
    }
}
