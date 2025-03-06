import UIKit


class DortHarflilerEkrani: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var letterBoxes: [CustomTextField]!
    var currentRowIndex: Int = 0
    var selectedword: String = " "
    var words: [String] = []
    var userGuesses: Set<String> = []
    
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var newWord: UIButton!
  
    @IBOutlet weak var back: UIButton!
    
    @IBAction func newWord(_ sender: Any) {
        resetGame()
    }
    @IBAction func back(_ sender: Any) {
    }
    
    func setupGrid() {
        let rows = 5
        let columns = 4
        
        let width: CGFloat = 50
        let height: CGFloat = 50
        let spacing: CGFloat = 26
        
        let totalWidth = CGFloat(columns) * width + CGFloat(columns - 1) * spacing
        let totalHeight = CGFloat(rows) * height + CGFloat(rows - 1) * spacing
        
        let startX = (view.frame.width - totalWidth) / 2
        let startY = (view.frame.height - totalHeight) / 2
        
        for r in 0..<rows {
            for c in 0..<columns {
                let i = r * columns + c
                if i < letterBoxes.count {
                    let box = letterBoxes[i]
                    box.translatesAutoresizingMaskIntoConstraints = false
                    
                    box.widthAnchor.constraint(equalToConstant: width).isActive = true
                    box.heightAnchor.constraint(equalToConstant: height).isActive = true
                    
                    if r == 0 && c == 0 {
                        box.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: startX).isActive = true
                        box.topAnchor.constraint(equalTo: view.topAnchor, constant: startY).isActive = true
                    } else if r == 0 {
                        box.leadingAnchor.constraint(equalTo: letterBoxes[i - 1].trailingAnchor, constant: spacing).isActive = true
                        box.topAnchor.constraint(equalTo: letterBoxes[0].topAnchor).isActive = true
                    } else if c == 0 {
                        box.leadingAnchor.constraint(equalTo: letterBoxes[0].leadingAnchor).isActive = true
                        box.topAnchor.constraint(equalTo: letterBoxes[i - columns].bottomAnchor, constant: spacing).isActive = true
                    } else {
                        box.leadingAnchor.constraint(equalTo: letterBoxes[i - 1].trailingAnchor, constant: spacing).isActive = true
                        box.topAnchor.constraint(equalTo: letterBoxes[i - columns].bottomAnchor, constant: spacing).isActive = true
                    }
                }
            }
        }
    }
    
    func loadWords() -> [String] {
        guard let fileURL = Bundle.main.url(forResource: "4harfliler", withExtension: "txt") else {
            return []
        }
        do {
            let content = try String(contentsOf: fileURL, encoding: .utf8)
            let words = content.components(separatedBy: "\n")
            return words.filter { !$0.isEmpty }
                .map { $0.uppercased(with: Locale(identifier: "tr_TR")) }
        } catch {
            print("Dosya okunurken hata: \(error)")
            return []
        }
    }
    
    func getRandomWord(from words: [String]) -> String? {
        guard !words.isEmpty else { return nil }
        let randomFourLetterWord = Int(arc4random_uniform(UInt32(words.count)))
        return words[randomFourLetterWord]
    }
    
    func disableTextFields() {
        for i in 1..<letterBoxes.count {
            letterBoxes[i].isUserInteractionEnabled = false
        }
    }
    
    func moveToNextTextField(currentTextField: UITextField) {
        if let currentIndex = letterBoxes.firstIndex(of: currentTextField as! CustomTextField) {
            var nextIndex = currentIndex + 1
            while nextIndex < letterBoxes.count {
                if letterBoxes[nextIndex].isUserInteractionEnabled {
                    letterBoxes[nextIndex].becomeFirstResponder()
                    break
                }
                nextIndex += 1
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text else { return true }
        let newLength = currentText.count + string.count - range.length
        
        if newLength == 1 {
            let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string).uppercased(with: Locale(identifier: "tr_TR"))
            textField.text = updatedText
            moveToNextTextField(currentTextField: textField)
            
            if isRowComplete() {
                checkUserGuess()
            }
            return false
        }
        return newLength <= 1
    }
    
    func isRowComplete() -> Bool {
        let startIndex = currentRowIndex * 4
        let endIndex = startIndex + 4
        
        for i in startIndex..<endIndex {
            if letterBoxes[i].text?.isEmpty ?? true {
                return false
            }
        }
        return true
    }
    
    func moveToNextRow() {
        let nextRowStartIndex = currentRowIndex * 4
        let prevRowStartIndex = (currentRowIndex - 1) * 4
        if nextRowStartIndex < letterBoxes.count {
            if prevRowStartIndex >= 0 {
                for i in 0..<4 {
                    letterBoxes[prevRowStartIndex + i].isUserInteractionEnabled = false
                }
            }
            for i in 0..<4 {
                let prevIndex = prevRowStartIndex + i
                let nextIndex = nextRowStartIndex + i
                
                if letterBoxes[prevIndex].backgroundColor == .green {
                    if i == 0 {
                        letterBoxes[nextIndex].text = letterBoxes[prevIndex].text
                        letterBoxes[nextIndex].isUserInteractionEnabled = false
                    } else {
                        letterBoxes[nextIndex].placeholder = letterBoxes[prevIndex].text
                        letterBoxes[nextIndex].isUserInteractionEnabled = true
                    }
                }
            }
            for i in 0..<4 {
                let nextIndex = nextRowStartIndex + i
                if letterBoxes[nextIndex].text == nil || letterBoxes[nextIndex].text == "" {
                    letterBoxes[nextIndex].becomeFirstResponder()
                    break
                }
            }
        }
    }
    
    func checkUserGuess() {
        let startIndex = currentRowIndex * 4
        let endIndex = startIndex + 4
        
        let selectedWordArray = Array(selectedword)
        var userGuess = ""
        
        for i in startIndex..<endIndex {
            userGuess += letterBoxes[i].text ?? ""
        }
        
        if userGuesses.contains(userGuess) {
            for i in startIndex..<endIndex {
                letterBoxes[i].backgroundColor = UIColor.red
                letterBoxes[i].text = String(selectedword[selectedword.index(selectedword.startIndex, offsetBy: i % 4)])
            }
            GameScore.shared.increseScore(by: 50)

            label.text = "Bu tahmini daha önce yapmıştınız"
            disableTextFields()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.performSegue(withIdentifier: "gameover", sender: nil)
            }
            return
        } else {
            userGuesses.insert(userGuess)
        }
        
        if !words.contains(userGuess) {
            for i in startIndex..<endIndex {
                letterBoxes[i].backgroundColor = UIColor.red
                letterBoxes[i].text = String(selectedword[selectedword.index(selectedword.startIndex, offsetBy: i % 4)])
            }
            label.text = "Böyle bir kelime bulunmamaktadır"
            
            GameScore.shared.decreaseScore(by: 50)

            disableTextFields()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.performSegue(withIdentifier: "gameover", sender: nil)
                self.newWord.isHidden=false

            }
            return
        }
        
        if userGuess == selectedword {
            GameScore.shared.increseScore(by: 100)

            for i in startIndex..<endIndex {
                letterBoxes[i].backgroundColor = UIColor.green
            }
            label.text = "Doğru Tahmin! \n Skor = \(GameScore.shared.score)"
            disableTextFields()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.newWord.isHidden = false
            }
        } else {
            var usedIndices = Set<Int>()
            
            for i in startIndex..<endIndex {
                let userLetter = letterBoxes[i].text ?? ""
                let correctLetter = String(selectedWordArray[i % 4])
                
                if userLetter == correctLetter {
                    letterBoxes[i].backgroundColor = UIColor.green
                    usedIndices.insert(i % 4)
                }
            }
            
            for i in startIndex..<endIndex {
                let userLetter = letterBoxes[i].text ?? ""
                if letterBoxes[i].backgroundColor != .green,
                   let indexInWord = selectedWordArray.firstIndex(of: Character(userLetter)),
                   !usedIndices.contains(indexInWord) {
                    letterBoxes[i].backgroundColor = UIColor.yellow
                    usedIndices.insert(indexInWord)
                }
            }
            
            currentRowIndex += 1
            if currentRowIndex < 5 {
                moveToNextRow()
            } else {
                disableTextFields()
                for i in startIndex..<endIndex {
                    letterBoxes[i].backgroundColor = UIColor.red
                    letterBoxes[i].text = String(selectedword[selectedword.index(selectedword.startIndex, offsetBy: i % 4)])
                    label.text = "Tahmin hakkınız bitti"
                    label.sizeToFit()

                    GameScore.shared.decreaseScore(by: 50)

                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.performSegue(withIdentifier: "gameover", sender: nil)
                    self.newWord.isHidden=false
                }
            }
        }
    }
    
    func resetGame() {
        newWord.isHidden = true
        for box in letterBoxes {
            box.text = ""
            box.backgroundColor = .white
            box.isUserInteractionEnabled = true
            box.placeholder = ""
            label.text = "Tahmininizi Giriniz"
            label.lineBreakMode = .byWordWrapping
            label.sizeToFit()
        }
        
        if let newWord = getRandomWord(from: words) {
            selectedword = newWord
        }
        
        letterBoxes[0].text = String(selectedword.first!)
        letterBoxes[0].isEnabled = false
        letterBoxes[1].becomeFirstResponder()
        currentRowIndex = 0
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGrid()
        UIHelper.setBackGroundColor(for:view)
        UIHelper.setButtons([newWord,back])
        UIHelper.animateButtons([newWord,back])
        UIHelper.label(for: label)
        UIHelper.letterBox(letterBoxes)
        
        newWord.isHidden = true
        label.text="Tahmininizi Giriniz"
        
        label.sizeToFit()
        label.numberOfLines=0
      

        for textField in letterBoxes {
            textField.delegate = self
        }
        
        words = loadWords()
        if let randomword = getRandomWord(from: words) {
            selectedword = randomword.uppercased(with: Locale(identifier: "tr_TR"))
        }
        
        for (index, textField) in letterBoxes.enumerated() {
            textField.delegate = self
            textField.backspaceAction = { [weak self] in
                if index > 0 {
                    self?.letterBoxes[index - 1].becomeFirstResponder()
                }
            }
        }
        
        letterBoxes[0].text = String(selectedword.first!)
        letterBoxes[0].isEnabled = false
        letterBoxes[1].becomeFirstResponder()
    }
}

