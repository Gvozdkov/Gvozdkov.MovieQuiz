import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    // MARK: - IBOutlet
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var nuButton: UIButton!
    @IBOutlet private var yesButton: UIButton!

    //MARK: - Private Properties
    private var rightAnswer: Int = 0
    private var currentQuestionIndex: Int = 0
    private var numberOfGames: Int = 1
    private var vrem = AlertPresenter.showAlert
    private var record = Set<Int>()
    
    private let questionsAmount: Int =  10                       // общее количество вопросов для квиза
    private var correctAnswers: Int = 0                          // правельные ответы
    
    private var currentQuestion: QuizQuestion?                    // текущий вопрос, который видит пользователь.
    private let alertPresenter = AlertPresenter()
    private var questionFactory: QuestionFactoryProtocol?        // та самая фабрика вопросов, которую мы создали. Наш                                                                   контроллер будет обращаться за вопросами именно к ней.
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = "inception.json"
        documentsURL.appendPathComponent(fileName)
        let jsonString = try? String(contentsOf: documentsURL)
        
        questionFactory = QuestionFactory(delegate: self)
        questionFactory?.requestNextQuestion()
        alertPresenter.viewController = self
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
    
    // MARK: - Private methods
    func reset() {
        currentQuestionIndex = 0
        correctAnswers = 0
        numberOfGames = 1
    }
    
    
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
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 0

        if currentQuestionIndex == questionsAmount - 1 {
            
            let titleText = "Этот раунд окончен!"
            let massageText = """
                Ваш результат: \(rightAnswer)/\(questionsAmount)
                Количество сыгранных квизов: \(numberOfGames)
                Рекорд: \(gameRecord(num: rightAnswer))/10 (\(date()))
                Средняя точность: \(rightAnswer * 10).00%
                """
            let buttonText = "Сыграть еще раз"
            
            
            let viewModel = AlertModel(title: titleText,
                                       message: massageText,
                                       buttonText: buttonText) { [weak self] in
//                self?.currentQuestionIndex = 1
//                self?.correctAnswers = 0
                self?.rightAnswer = 0
                self?.numberOfGames = 1
                //                self?.questionFactory?.requestNextQuestion()
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
