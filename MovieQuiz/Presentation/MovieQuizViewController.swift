import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    // MARK: - IBOutlet
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
   
  
    
    //MARK: - Private Properties

    private var correctAnswers: Int = 0                          // правельные ответы
    
    private var currentQuestion: QuizQuestion?                    // текущий вопрос, который видит пользователь.
    private var statisticService: StatisticService?
    private var questionFactory: QuestionFactoryProtocol?        // та самая фабрика вопросов, которую мы создали. Наш                                                          контроллер будет обращаться за вопросами именно к ней.
    private let alertPresenter = AlertPresenter()
    private let presenter = MovieQuizPresenter()
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        alertPresenter.viewController = self
        statisticService = StatisticServiceImplementation()
        
        showLoadingIndicator()
        questionFactory?.loadData()

    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    

    // MARK: - Private methods
    override var preferredStatusBarStyle: UIStatusBarStyle {  //изменение цвета статус бара
        return .lightContent
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false // говорим, что индикатор загрузки не скрыт
        activityIndicator.startAnimating() // включили анимацию
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    
    private func showNetworkError(message: String) {
        activityIndicator.isHidden = true // скрываем индикатор загрузки

        let alert = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert)

        let action = UIAlertAction(title: "Попробовать еще раз",
                                   style: .default) { [weak self] _ in
            guard let self = self else { return }

            self.presenter.currentQuestionIndex = 0
            self.correctAnswers = 0

            self.questionFactory?.requestNextQuestion()
        }

        alert.addAction(action)
    }
 

    private func show(quiz step: QuizStepViewModel) {           // здесь мы заполняем нашу картинку, текст и счётчик данными
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func showAnswerResult(isCorrect: Bool) {           // здесь показываем результат ответа в виде рамки зеленой
        
        imageView.layer.masksToBounds = true                   // даём разрешение на рисование рамки
        imageView.layer.borderWidth = 8                        // толщина рамки
        imageView.layer.cornerRadius = 20                       // радиус скругления углов рамки
        
        if isCorrect == true {
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
            correctAnswers += 1
        } else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor
        }

        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
        noButton.isEnabled = true
        yesButton.isEnabled = true
    }

    private func show(quiz result: QuizResultsViewModel) {
        var message = result.text
        if let statisticService = statisticService {
            statisticService.store(correct: correctAnswers, total: presenter.questionsAmount)
            
            let bestGame = statisticService.bestGame
            
            let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
            let currentGameResultLine = "Ваш результат: \(correctAnswers)\\\(presenter.questionsAmount)"
            let bestGameInfoLine = "Рекорд: \(bestGame.correct)\\\(bestGame.total)"
            + " (\(bestGame.date.dateTimeString))"
            let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
            
            let resultMessage = [
                currentGameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine
            ].joined(separator: "\n")
            
            message = resultMessage
        }
        
        let model = AlertModel(title: result.title, message: message, buttonText: result.buttonText) { [weak self] in
            guard let self = self else { return }
            
            self.presenter.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            self.questionFactory?.requestNextQuestion()
        }
        
        alertPresenter.showAlert(model: model)
    }
    
    private func showNextQuestionOrResults() {
        blockButton()
        if presenter.currentQuestionIndex == presenter.questionsAmount - 1 {
            let text = "Вы ответили на \(correctAnswers) из 10, попробуйте еще раз!"

            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            show(quiz: viewModel)
        } else {
            presenter.currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
    
//    private func showNextQuestionOrResults() {
//        imageView.layer.borderWidth = 0
//        noButton.isEnabled = true
//        yesButton.isEnabled = true
//
//        imageView.layer.masksToBounds = true
//        imageView.layer.borderWidth = 0
//
//        if currentQuestionIndex == questionsAmount - 1 {
//
//            guard let statisticService = statisticService else { return }
//
//            statisticService.store(correct: correctAnswers, total: questionsAmount)
//            let accurancyProcentage = "\(String(format: "%.2f", statisticService.totalAccuracy))%"
//            let bestGameDate = statisticService.bestGame.date.dateTimeString
//            let totalGamesCount = statisticService.gamesCount
//            let currentCorrectRecord = statisticService.bestGame.correct
//            let currentTotalRecord = statisticService.bestGame.total
//
//            let titleText = "Этот раунд окончен!"
//            let massageText = """
//                Ваш результат: \(correctAnswers)/\(questionsAmount)
//                Количество сыгранных квизов: \(totalGamesCount)
//                Рекорд: \(currentCorrectRecord)/\(currentTotalRecord) (\(bestGameDate))
//                Средняя точность: \(accurancyProcentage)
//                """
//            let buttonText = "Cыграть еще раз"
//
//
//            let viewModel = AlertModel(title: titleText,
//                                       message: massageText,
//                                       buttonText: buttonText) { [weak self] in
//                self?.currentQuestionIndex = 0
//                self?.correctAnswers = 0
//
//                self?.questionFactory?.requestNextQuestion()
//            }
//            showQuizAlert(quiz: viewModel)
//        } else {
//            currentQuestionIndex += 1
//            questionFactory?.requestNextQuestion()
//        }
//    }
    
//    private func showQuizAlert(quiz model: AlertModel) {
//        alertPresenter.showAlert(model: model)
//    }
//
    func blockButton() {
        noButton.isEnabled = true
        yesButton.isEnabled = true
        imageView.layer.borderWidth = 0
    }
    
    // MARK: - IBActions

    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let answer: Bool = false
        showAnswerResult(isCorrect: answer == currentQuestion.correctAnswer)
    }
    

    @IBAction private func yesButtonClickd(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let answer: Bool = true
        showAnswerResult(isCorrect: answer == currentQuestion.correctAnswer)
    }
    
}

