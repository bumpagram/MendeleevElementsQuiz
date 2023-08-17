//
//  ViewController.swift
//  MendeleevElementsQuiz
//
//  Created by Denis Azarkov on 02.05.23.
//

import UIKit

enum GameMode {
    case flashCard
    case quiz
}
enum State {
    case question
    case answer
    case score
}

class ViewController: UIViewController, UITextFieldDelegate {
    let fixedElementList = ["Carbon", "Gold", "Chlorine","Sodium"]
    var elementList: [String] = []  //массив сделал var тк в квизе он будет специально перемешан
    var currentElementIndex = 0  //чтобы чекать какой элемент отображается сейчас
    
    var gamemode: GameMode = .flashCard {
        didSet {
            switch gamemode {
            case .flashCard:  setupFlashCards()
            case .quiz:  setupQuiz()
            }
            updateglobalUI()
        }
    }
    
    var gamestate : State = .question
    //ниже 2 проперти для квиза. ответ правильный/нет и счетчик очков
    var answerIsCorrect = false
    var correctAnswersCount = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view
        gamemode = .flashCard
    }
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var answerLabel: UILabel!
    
    func updateglobalUI() {
        let elementName = elementList[currentElementIndex]
        let currentImage = UIImage(named: elementName) // инициализатор ищет по стринг в Ассетах файл с таким же именем и выводит его в окно потом
        imageView.image = currentImage  // чз метод .image от UIImageView назначаем какое изображение выводить

        switch gamemode { // оперируем не самим энумом, а свойством класса куда он передан
        case .flashCard: updateFlashCardUI(elementName: elementName)
        case .quiz: updateQuizUI(elementName: elementName)
        }
    }
    
    func updateFlashCardUI(elementName: String) {
        showAnswerButton.isHidden = false
        nextButton.isEnabled = true
        nextButton.setTitle("Next Element", for: .normal)
        textField.isHidden = true
        textField.resignFirstResponder()
        modeSelector.selectedSegmentIndex = 0  // апдейт сегментной кнопки
        if gamestate == .answer {
            answerLabel.text = elementName
        }
        else {
            answerLabel.text = "?"
        }
    }
    
    func updateQuizUI(elementName : String) {
        showAnswerButton.isHidden = true
        textField.isHidden = false
        modeSelector.selectedSegmentIndex = 1  // апдейт сегментной кнопки
        if currentElementIndex == elementList.count - 1 {
            nextButton.setTitle("Show Score", for: .normal)
        }
        else {
            nextButton.setTitle("Next Question", for: .normal)
        }
        switch gamestate {
        case .question:
            textField.isEnabled = true
            textField.text = ""
            textField.becomeFirstResponder()
            nextButton.isEnabled = false
        case .answer:
            textField.isEnabled = false
            textField.resignFirstResponder()
            nextButton.isEnabled = true
        case .score :
            nextButton.isEnabled = false
            textField.isHidden = true
            textField.resignFirstResponder()
            displayScoreAlert()
        }

        switch gamestate {
        case .question : answerLabel.text = ""
        case .answer :
            if answerIsCorrect { answerLabel.text = "Correct!"
            }
            else { answerLabel.text = "❌\nCorrect Answer: " + elementName
            }
        case .score :
            answerLabel.text = ""
        }
    }

    
    @IBAction func showAnswer(_ sender: UIButton) {
        gamestate = .answer
        updateglobalUI()
    }
    @IBAction func next(_ sender: UIButton) {
        currentElementIndex += 1
        if currentElementIndex >= elementList.count  {
            currentElementIndex = 0
            if gamemode == .quiz {
                gamestate = .score
                updateglobalUI()
                return
            }
        }
        gamestate = .question
        updateglobalUI()
    }
    
    @IBAction func switchmodes(_ sender: UISegmentedControl) {
        if modeSelector.selectedSegmentIndex == 0 { gamemode = .flashCard}
        else { gamemode = .quiz }
        // можно было вызвать updateglobalUI()  но я заюзал didset в свойстве gamemode
    }
    @IBOutlet weak var modeSelector: UISegmentedControl!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var showAnswerButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    //коллбэк-метод из ассортимента UITextFieldDelegate. запускается когда юзер нажимает enter(return) на виртуальной клавиатуре
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //получаем содержимое текстового поля, force unwrapped
        let gotTextContent = textField.text!
        if gotTextContent.lowercased() == elementList[currentElementIndex].lowercased() {
            answerIsCorrect = true
            correctAnswersCount += 1
        }
        else {
            answerIsCorrect = false
        }
        // теперь надо отобразить результат. переходим в режим ответов
        gamestate = .answer
        updateglobalUI()
        return true
    }
  // Alert -уведомление
    func displayScoreAlert() {
        let showAlert = UIAlertController(title: "Quiz score", message: "Your score is \(correctAnswersCount) out of \(elementList.count)", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "OK", style: .default, handler: scoreAlertDismissed(_:))   // handler - это callback
        showAlert.addAction(dismissAction)
        present(showAlert, animated: true, completion: nil)
    }
    func scoreAlertDismissed(_ setAction: UIAlertAction) {
        gamemode = .flashCard
        gamestate = .question
    }
  //
    func setupFlashCards() {
        gamestate = .question
        currentElementIndex = 0
        elementList = fixedElementList
    }
    func setupQuiz() {
        gamestate = .question
        currentElementIndex = 0
        answerIsCorrect = false
        correctAnswersCount = 0
        elementList = fixedElementList.shuffled()
    }
    
}

