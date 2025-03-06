//
//  AltiHarflilerEkrani.swift
//  kelimeOyunu
//
//  Created by ceyda oymak on 19.10.2024.
//

class CustomTextField: UITextField {
    var backspaceAction: (() -> Void)?
    
    override func deleteBackward() {
        if let backspaceAction = backspaceAction {
            backspaceAction()
        }
        super.deleteBackward()
    }
}
import UIKit

class AltiHarflilerEkrani: UIViewController, UITextFieldDelegate{
    
    @IBOutlet var letterBoxes: [CustomTextField]!
    
    var words:[String]=[]
    var currentRowIndex:Int=0
    
    @IBOutlet weak var label: UILabel!
    
    var selectedword:String=" "
    var userGuesses: Set<String> = []
    
    @IBOutlet weak var newWord: UIButton!
    
    @IBOutlet weak var back: UIButton!
    
    @IBAction func newWord(_ sender: Any) {
        resetGame()
    }
    
    @IBAction func back(_ sender: Any) {
    }
    
    func setupGrid() {
        let rows = 5
        let columns = 6
        
        let width: CGFloat = 45
        let height: CGFloat = 45
        let spacing: CGFloat = 18
        
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
                    box.widthAnchor.constraint(equalToConstant: width).priority = UILayoutPriority(999)

                    if r == 0 && c == 0 {
                        box.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: startX).isActive = true
                        box.topAnchor.constraint(equalTo: view.topAnchor, constant: startY).isActive = true
                    }
                    
                    else if r == 0 {
                        box.leadingAnchor.constraint(equalTo: letterBoxes[i - 1].trailingAnchor, constant: spacing).isActive = true
                        box.topAnchor.constraint(equalTo: letterBoxes[0].topAnchor).isActive = true
                    }
                    
                    else if c == 0 {
                        box.leadingAnchor.constraint(equalTo: letterBoxes[0].leadingAnchor).isActive = true
                        box.topAnchor.constraint(equalTo: letterBoxes[i - columns].bottomAnchor, constant: spacing).isActive = true
                    }
                    
                    else {
                        box.leadingAnchor.constraint(equalTo: letterBoxes[i - 1].trailingAnchor, constant: spacing).isActive = true
                        box.topAnchor.constraint(equalTo: letterBoxes[i - columns].bottomAnchor, constant: spacing).isActive = true
                    }
                }
            }
        }
    }
    func loadWords() -> [String]{
        guard let fileURL=Bundle.main.url(forResource: "6harfliler", withExtension: "txt") else {
            return []
        }
        do {
            let content = try String(contentsOf: fileURL,encoding: .utf8)
            let words = content.components(separatedBy: "\n")
            
            return words.filter{!$0.isEmpty}
                .map { $0.uppercased(with: Locale(identifier: "tr_TR")) }
            
            
        } catch {
            print("dosya hatası")
            return []
        }
    }
    
    
    
    func getRandomWord(from words: [String])->String?{
        guard !words.isEmpty else {return nil}
        let randomSixLetterWord=Int(arc4random_uniform(UInt32(words.count)))
        return words[randomSixLetterWord]
        
    }
    func disableTextFields(){
        for i in 1..<letterBoxes.count{
            letterBoxes[i].isUserInteractionEnabled=false
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

        if string.isEmpty {
           
            if let currentIndex = letterBoxes.firstIndex(of: textField as! CustomTextField) {
                    letterBoxes[currentIndex].text=""
                    let previousIndex = currentIndex - 1
                    if previousIndex >= 0 {
                        let previousTextField = letterBoxes[previousIndex]
                        previousTextField.becomeFirstResponder()
                    }
                }
                return false
            
        }
            
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
        let startIndex = currentRowIndex*6
        let endIndex = startIndex + 6
        
        if currentRowIndex==0{
            for i in (startIndex+1)..<endIndex{
                if letterBoxes[i].text?.isEmpty ?? true {
                    return false
                }
            }
            return true
        }
        else {
            for i in (startIndex..<endIndex){
                if letterBoxes[i].text?.isEmpty ?? true {
                    return false
                }
            }
            return true
        }
    }
    func moveToNextRow() {
        let nextRowStartIndex = currentRowIndex * 6
        let prevRowStartIndex = (currentRowIndex - 1) * 6
        if nextRowStartIndex < letterBoxes.count {
            
            if prevRowStartIndex >= 0 {
                for i in 0..<6 {
                    letterBoxes[prevRowStartIndex + i].isUserInteractionEnabled = false
                }
            }
            for i in 0..<6 {
                let prevIndex = prevRowStartIndex + i
                let nextIndex = nextRowStartIndex + i
                
                if letterBoxes[prevIndex].backgroundColor == .green {
                    if i==0{
                        letterBoxes[nextIndex].text = letterBoxes[prevIndex].text
                        letterBoxes[nextIndex].isUserInteractionEnabled=false

                    }else{
                        letterBoxes[nextIndex].placeholder = letterBoxes[prevIndex].text
                        letterBoxes[nextIndex].isUserInteractionEnabled = true

                    }
                }
            }
            
            for i in 0..<6 {
                let nextIndex = nextRowStartIndex + i
                if letterBoxes[nextIndex].text == nil || letterBoxes[nextIndex].text == "" {
                    letterBoxes[nextIndex].becomeFirstResponder()
                    break
                }
            }
        }
    }
    func checkUserGuess() {
        
        let startIndex = currentRowIndex * 6
        let endIndex = startIndex + 6
        
        let selectedWordArray=Array(selectedword)
        
        guard endIndex <= letterBoxes.count else {
            return
        }
        
        var userGuess = ""
        
        for i in startIndex..<endIndex {
            userGuess += letterBoxes[i].text ?? ""
        }
        
        if userGuesses.contains(userGuess) {
            for i in startIndex..<endIndex {
                letterBoxes[i].backgroundColor = UIColor.red
                letterBoxes[i].text = String(selectedword[selectedword.index(selectedword.startIndex, offsetBy: i % 6)])
            }
            GameScore.shared.increseScore(by: 50)
            label.text = "Bu tahmini daha önce yapmıştınız"
            label.sizeToFit()
           
            disableTextFields()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.performSegue(withIdentifier: "gameover3", sender: nil)
                self.newWord.isHidden=false

                
            }
            return
        } else {
                    userGuesses.insert(userGuess)
                }
                
                if !words.contains(userGuess) {
                    for i in startIndex..<endIndex {
                        letterBoxes[i].backgroundColor = UIColor.red
                        letterBoxes[i].text = String(selectedword[selectedword.index(selectedword.startIndex, offsetBy: i % 6)])
                    }
                    disableTextFields()
                    label.text = "Böyle bir kelime bulunmamaktadır"
                    label.sizeToFit()
                    label.numberOfLines=0
                    label.lineBreakMode = .byWordWrapping
                    GameScore.shared.decreaseScore(by: 50)

                 
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        self.performSegue(withIdentifier: "gameover3", sender: nil)
                        self.newWord.isHidden=false

                    }
                    return
                }
        
        if userGuess == selectedword {
            GameScore.shared.increseScore(by: 100)

            for i in startIndex..<endIndex{ 
                letterBoxes[i].backgroundColor = UIColor.green
                label.text="Doğru Tahmin!"
                label.sizeToFit()
                disableTextFields()
                newWord.isHidden=false
                
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.newWord.isHidden=false
            }
        } else {
            
            var usedIndices = Set<Int>()

            for i in startIndex..<endIndex{
                
                let userLetter=letterBoxes[i].text ?? ""
                let correctLetter=String(selectedWordArray[i%6])
                
                if  userLetter == correctLetter{
                    letterBoxes[i].backgroundColor = UIColor.green
                    usedIndices.insert(i % 6)
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
            if currentRowIndex < 6 {
                moveToNextRow()
            } else {
                disableTextFields()
                
                for i in startIndex..<endIndex{
                    letterBoxes[i].backgroundColor = UIColor.red
                    letterBoxes[i].text = String(selectedword[selectedword.index(selectedword.startIndex, offsetBy: i % 6)])
                    label.text="Tahmin hakkınız bitti"
                    label.sizeToFit()
                    GameScore.shared.decreaseScore(by: 50)

                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.performSegue(withIdentifier: "gameover3", sender: nil)
                }
            }
        }
    }
    func resetGame() {
        newWord.isHidden=true
        for box in letterBoxes {
            box.text = ""
            box.backgroundColor = .white
            box.isUserInteractionEnabled = true
            box.placeholder = ""
            label.text="Tahmininizi Giriniz"
        }
        
        if let newWord = getRandomWord(from: words) {
            selectedword = newWord
            print("Yeni kelime: \(selectedword)")
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
        UIHelper.label(for: label)
        UIHelper.letterBox(letterBoxes)
    
        newWord.isHidden=true
        label.text="Tahmininizi Giriniz"
        label.sizeToFit()
        words=loadWords()
        
        for textField in letterBoxes {
            textField.delegate = self
        }
        if let randomword=getRandomWord(from: words)
        {
            selectedword=randomword.uppercased(with: Locale(identifier: "tr_TR"))
        }
        for (index, textField) in letterBoxes.enumerated() {
                   textField.delegate = self
                   textField.backspaceAction = { [weak self] in
                       if index > 0 {
                           self?.letterBoxes[index - 1].becomeFirstResponder()
                       }
                   }
               }
       print(selectedword)
        letterBoxes[0].text = String(selectedword.first!)
        letterBoxes[0].isEnabled = false
        letterBoxes[1].becomeFirstResponder()
        
    }
}
