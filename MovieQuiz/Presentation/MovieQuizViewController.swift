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
        show(quiz: convert(model: questions[currentQuestionIndex]))
    }
    
    
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    private var rightAnswer: Int = 0
    private var numberOfGames: Int = 1
    private var record = Set<Int>()
    
    
    private struct QuizStepViewModel {                          // для состояния "Вопрос задан"
      let image: UIImage
      let question: String
      let questionNumber: String
    }

    
    private struct QuizResultsViewModel {                       // для состояния "Результат квиза"
      let title: String
      let text: String
      let buttonText: String
    }
    
        
    private struct QuizQuestion {                               // для информации на экране
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
    
    
    private func date() -> String {
        let date = Date()
        let currentDate = DateFormatter()
        currentDate.dateFormat = "dd.MM.yy hh:mm"
        let now = currentDate.string(from: date)
        return now
    }
    
    
    private func gameRecord(num: Int) -> Int {
        record.insert(num)
        return record.max() ?? 0
    }
   
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {    // тут конвертируем информацию для экрана в состояние "Вопрос задан"
    return QuizStepViewModel(
        image: UIImage(named: model.image) ?? UIImage(),
        question: model.text,
        questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)")
      }
    

    private func show(quiz step: QuizStepViewModel) {           // здесь мы заполняем нашу картинку, текст и счётчик данными
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber

    }
    
    
    private func showResultQuiz() {                             // здесь мы показываем результат прохождения квиза
        let alert = UIAlertController(
            title: "Этот раунд окончен!",                       // создаем аларт и даем заголовок
            message: "Ваш результат: \(rightAnswer)/10 \n Количество сыгранных квизов: \(numberOfGames) \n Рекорд: \(gameRecord(num: rightAnswer))/10 (\(date())) \n Средняя точность: \(rightAnswer * 10).00%",                       // сообщение
            preferredStyle: .alert)                             // тип оповещение .alert или .actionSheet
        
        let action = UIAlertAction(title: "Сыграть еще раз", style: .default) { _ in // создаём для него кнопки с действиями
            self.numberOfGames += 1
            self.currentQuestionIndex = 0
                                                                // заново показываем первый вопрос
            let firstQuestion = self.questions[self.currentQuestionIndex]
            let viewModel = self.convert(model: firstQuestion)
            self.show(quiz: viewModel)
            self.rightAnswer = 0
        }
        
        alert.addAction(action)                                 // добавляем в алерт кнопки
        self.present(alert, animated: true, completion: nil)    // показываем всплывающее окно
    }
    
    
    private func showAnswerResult(isCorrect: Bool) {           // здесь показываем результат ответа в виде рамки зеленой или красной
        imageView.layer.masksToBounds = true                   // даём разрешение на рисование рамки
        imageView.layer.borderWidth = 8                        // толщина рамки
        imageView.layer.cornerRadius = 6                       // радиус скругления углов рамки

        if isCorrect == true {
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
            correctAnswers += 1
            rightAnswer += 1
        } else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor
        }
        nuButton.isEnabled = false
        yesButton.isEnabled = false
    }
    
    
    private func blockShowAnswerResult() {
        imageView.layer.borderWidth = 0
        nuButton.isEnabled = true
        yesButton.isEnabled = true
    }
    
    
    private func showNextQuestionOrResults() {
     if currentQuestionIndex == questions.count - 1 {
         showResultQuiz()                                               // показать результат квиза
      } else {
        currentQuestionIndex += 1                                       // увеличиваем индекс текущего урока на 1; таким образом мы сможем получить следующий урок
          show(quiz: convert(model: questions[currentQuestionIndex]))   // показать следующий вопрос
      }
    }
    
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        let answer: Bool = false
        let answerTheQuestion = questions[currentQuestionIndex]
        showAnswerResult(isCorrect: answer == answerTheQuestion.correctAnswer)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {         // задержка вывода в 1 секунду
            self.showNextQuestionOrResults()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.blockShowAnswerResult()
        }
    }
    
    
    @IBAction private func yesButtonClickd(_ sender: Any) {
        let answer: Bool = true
        let answerTheQuestion = questions[currentQuestionIndex]
        showAnswerResult(isCorrect: answer == answerTheQuestion.correctAnswer)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResults()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.blockShowAnswerResult()
        }
    }
    
}
