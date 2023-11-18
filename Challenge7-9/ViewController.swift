import UIKit

class ViewController: UIViewController {
    var mistakesLabel: UILabel!
    var wordLabel: UILabel!
    var buttonsView: UIView!
    var letterButtons = [UIButton]()
    var words = [String]()
    var wordToGuess = ""
    let alphabet = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    var mistakesLeft = 7 {
        didSet {
            mistakesLabel.text = "Mistakes till death: \(mistakesLeft)"
        }
    }
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        
        mistakesLabel = UILabel()
        mistakesLabel.translatesAutoresizingMaskIntoConstraints = false
        mistakesLabel.text = "Mistakes till death: \(mistakesLeft)"
        mistakesLabel.font = UIFont.systemFont(ofSize: 25)
        mistakesLabel.textAlignment = .left
        view.addSubview(mistakesLabel)
        
        wordLabel = UILabel()
        wordLabel.translatesAutoresizingMaskIntoConstraints = false
        wordLabel.font = UIFont.systemFont(ofSize: 90)
        wordLabel.text = ""
        view.addSubview(wordLabel)
        
        buttonsView = UIView()
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonsView)
        
        NSLayoutConstraint.activate([
            mistakesLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            mistakesLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            mistakesLabel.widthAnchor.constraint(equalToConstant: 300),
            
            wordLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            wordLabel.bottomAnchor.constraint(equalTo: buttonsView.topAnchor, constant: -100),
            wordLabel.heightAnchor.constraint(equalToConstant: 100),
            
            buttonsView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
            buttonsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonsView.widthAnchor.constraint(equalToConstant: 700),
            buttonsView.heightAnchor.constraint(equalToConstant: 400)
        ])
        
        var counter = 0
        for row in 0..<4 {
            for column in 0..<7 {
                if row == 3 && (column == 0 || column == 6) {
                    continue
                }
                
                let letterButton = UIButton(type: .system)
                letterButton.titleLabel?.font = UIFont.systemFont(ofSize: 35)
                letterButton.setTitle(alphabet[counter], for: .normal)
                letterButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
                let frame = CGRect(x: column * 100, y: row * 100, width: 100, height: 100)
                letterButton.frame = frame
                buttonsView.addSubview(letterButton)
                letterButtons.append(letterButton)
                
                counter += 1
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        performSelector(inBackground: #selector(loadGame), with: nil)
    }
    
    @objc func loadGame() {
        if let urlString = Bundle.main.url(forResource: "words", withExtension: "txt") {
            if let wordsString = try? String(contentsOf: urlString) {
                words = wordsString.components(separatedBy: "\n")
                loadNewGame()
            }
        }
    }
    
    @objc func loadNewGame(action: UIAlertAction! = nil) {
        DispatchQueue.main.async { [weak self] in
            if let letterButtons = self?.letterButtons {
                for button in letterButtons {
                    button.isHidden = false
                }
            }
            self?.mistakesLeft = 7
        }
        
        wordToGuess = words.randomElement()?.uppercased() ?? "PARROT"
        
        DispatchQueue.main.async { [weak self] in
            var wordLabelText = ""
            if let size = self?.wordToGuess.count {
                for _ in 0..<size {
                    wordLabelText += "_ "
                }
                self?.wordLabel.text = wordLabelText.trimmingCharacters(in: .whitespaces)
            }
        }
    }
    
    @objc func buttonTapped(_ sender: UIButton) {
        sender.isHidden = true
        
        if let buttonLetter = sender.titleLabel?.text {
            let buttonCharacter = Character(buttonLetter)
            
            if let wordLabelText = wordLabel.text {
                var letters = wordLabelText.components(separatedBy: " ")
                var counter = 0
                
                for (index, letter) in wordToGuess.enumerated() {
                    if buttonCharacter == letter {
                        letters[index] = String(letter)
                        counter += 1
                    }
                }
                
                wordLabel.text = letters.joined(separator: " ")
                let wordToCompare = letters.joined()
                
                if wordToCompare == wordToGuess {
                    let ac = UIAlertController(title: "Congratulations!", message: "You guessed the word!", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "New Game", style: .default, handler: loadNewGame))
                    present(ac, animated: true)
                }
                
                if counter == 0 {
                    mistakesLeft -= 1
                    if mistakesLeft == 0 {
                        let ac = UIAlertController(title: "Game Over", message: "You lost!\nThe word was \(wordToGuess)", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "New Game", style: .default, handler: loadNewGame))
                        present(ac, animated: true)
                    }
                }
            }
        }
    }


}

