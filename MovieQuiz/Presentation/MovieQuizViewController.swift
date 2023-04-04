import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    // MARK: - IBOutlet
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var nuButton: UIButton!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    //MARK: - Private Properties
    private var currentQuestionIndex: Int = 0
    private let questionsAmount: Int =  10                       // общее количество вопросов для квиза
    private var correctAnswers: Int = 0                          // правельные ответы
    
    private var currentQuestion: QuizQuestion?                    // текущий вопрос, который видит пользователь.
    private let alertPresenter = AlertPresenter()
    private var statisticService: StatisticService?
    private var questionFactory: QuestionFactoryProtocol?        // та самая фабрика вопросов, которую мы создали. Наш                                                                   контроллер будет обращаться за вопросами именно к ней.
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.requestNextQuestion()
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
        let viewModel = convert(model: question)
        
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
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false // говорим, что индикатор загрузки не скрыт
        activityIndicator.startAnimating() // включили анимацию
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator() // скрываем индикатор загрузки
        

            let model = AlertModel(title: "Ошибка",
                                   message: message,
                                   buttonText: "Попробывать еще раз") { [weak self] in
                guard let self = self else { return }
                
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                self.questionFactory?.requestNextQuestion()
        }
        alertPresenter.showAlert(model: model)
    } 
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {    // тут конвертируем информацию для экрана в состояние "Вопрос задан"
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    
    private func show(quiz step: QuizStepViewModel) {           // здесь мы заполняем нашу картинку, текст и счётчик данными
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    
    private func showAnswerResult(isCorrect: Bool) {           // здесь показываем результат ответа в виде рамки зеленой или красной
        imageView.layer.masksToBounds = true                   // даём разрешение на рисование рамки
        imageView.layer.borderWidth = 8                        // толщина рамки
        imageView.layer.cornerRadius = 20                       // радиус скругления углов рамки
        
        if isCorrect == true {
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
            correctAnswers += 1
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
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 0

        if currentQuestionIndex == questionsAmount - 1 {
           
            guard let statisticService = statisticService else { return }

            statisticService.store(correct: correctAnswers, total: questionsAmount)
            let accurancyProcentage = "\(String(format: "%.2f", statisticService.totalAccuracy))%"
            let bestGameDate = statisticService.bestGame.date.dateTimeString
            let totalGamesCount = statisticService.gamesCount
            let currentCorrectRecord = statisticService.bestGame.correct
            let currentTotalRecord = statisticService.bestGame.total
            
            let titleText = "Этот раунд окончен!"
            let massageText = """
                Ваш результат: \(correctAnswers)/\(questionsAmount)
                Количество сыгранных квизов: \(totalGamesCount)
                Рекорд: \(currentCorrectRecord)/\(currentTotalRecord) (\(bestGameDate))
                Средняя точность: \(accurancyProcentage)
                """
            let buttonText = "Cыграть еще раз"
            
            
            let viewModel = AlertModel(title: titleText,
                                       message: massageText,
                                       buttonText: buttonText) { [weak self] in
                self?.currentQuestionIndex = 0
                self?.correctAnswers = 0
                
                self?.questionFactory?.requestNextQuestion()
            }
            showQuizAlert(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
    // MARK: - IBActions
            
    @IBAction private func noButtonClicked(_ sender: Any) {
        let answer: Bool = false
        guard let answerTheQuestion = currentQuestion else {
            return
        }
        showAnswerResult(isCorrect: answer == answerTheQuestion.correctAnswer)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in        // задержка вывода в 1 секунду. Делаем слабую ссылку и распаковываем через guard
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in        // задержка вывода в 1 секунду
            guard let self = self else { return }
            self.blockShowAnswerResult()
        }
    }
    
    private func showQuizAlert(quiz model: AlertModel) {
        alertPresenter.showAlert(model: model)
    }
    
    
    @IBAction private func yesButtonClickd(_ sender: Any) {
        let answer: Bool = true
        guard let answerTheQuestion = currentQuestion else {
            return
        }
        showAnswerResult(isCorrect: answer == answerTheQuestion.correctAnswer)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.blockShowAnswerResult()
        }
    }
    
}

