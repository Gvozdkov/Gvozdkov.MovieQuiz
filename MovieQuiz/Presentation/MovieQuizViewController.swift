import UIKit

final class MovieQuizViewController: UIViewController {
    // MARK: - Lifecycle
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    
    @IBOutlet private var nuButton: UIButton!
    @IBOutlet private var yesButton: UIButton!
    
    private var currentQuestionIndex: Int = 0
    
    private let questionsAmount: Int =  10                              // общее количество вопросов для квиза
    private let questionFactory: QuestionFactory = QuestionFactory()    // та самая фабрика вопросов, которую мы создали. Наш контроллер будет обращаться за вопросами именно к ней.
    private var currentQuestion: QuizQuestion?                          // текущий вопрос, который видит пользователь.
    
    private var correctAnswers: Int = 0
    private var rightAnswer: Int = 0
    private var numberOfGames: Int = 1
    private var record = Set<Int>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        show(quiz: convert(model: questions[currentQuestionIndex]))
        if let firstQuestion = questionFactory.requestNextQuestion() {
            currentQuestion = firstQuestion
            let viewModel = convert(model: firstQuestion)
            show(quiz: viewModel)
        }
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
    
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {    // тут конвертируем информацию для экрана в состояние "Вопрос задан"
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
    
    
    private func showResultQuiz() {                             // здесь мы показываем результат прохождения квиза
        let alert = UIAlertController(
            title: "Этот раунд окончен!",                       // создаем аларт и даем заголовок
            message: "Ваш результат: \(rightAnswer)/10 \n Количество сыгранных квизов: \(numberOfGames) \n Рекорд: \(gameRecord(num: rightAnswer))/10 (\(date())) \n Средняя точность: \(rightAnswer * 10).00%",                       // сообщение
            preferredStyle: .alert)                             // тип оповещение .alert или .actionSheet
        
        let action = UIAlertAction(title: "Сыграть еще раз", style: .default) { _ in // создаём для него кнопки с действиями
            self.numberOfGames += 1
            self.currentQuestionIndex = 0
                                                                // заново показываем первый вопрос
//            let firstQuestion = self.questions[self.currentQuestionIndex]
//            let viewModel = self.convert(model: firstQuestion)
//            self.show(quiz: viewModel)
            if let firstQuestion = self.questionFactory.requestNextQuestion() {
                self.currentQuestion = firstQuestion
                let viewModel = self.convert(model: firstQuestion)
                self.show(quiz: viewModel)
            }
            self.rightAnswer = 0
        }
        
        alert.addAction(action)                                 // добавляем в алерт кнопки
        self.present(alert, animated: true, completion: nil)    // показываем всплывающее окно
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
        if currentQuestionIndex == questionsAmount - 1 {
            showResultQuiz()                                               // показать результат квиза
        } else {
            currentQuestionIndex += 1                                      // увеличиваем индекс текущего урока на 1; таким образом мы сможем получить следующий урок
//            show(quiz: convert(model: questions[currentQuestionIndex]))    // показать следующий вопрос
            if let firstQuestion = self.questionFactory.requestNextQuestion() {
                self.currentQuestion = firstQuestion
                let viewModel = self.convert(model: firstQuestion)
                
                self.show(quiz: viewModel)
            }
        }
    }
    
    
    
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        let answer: Bool = false
//        let answerTheQuestion = questions[currentQuestionIndex]
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
    
    
    @IBAction private func yesButtonClickd(_ sender: Any) {
        let answer: Bool = true
//        let answerTheQuestion = questions[currentQuestionIndex]
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
