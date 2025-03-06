//
//  WelcomePage.swift
//  KelimeyiBul!
//
//  Created by ceyda oymak on 7.02.2025.
//

import UIKit
class WelcomePage: UIViewController {
    
    @IBAction func button3(_ sender: Any) {
    }
    @IBAction func button2(_ sender: Any) {
    }
    @IBAction func button1(_ sender: Any) {
    }
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button1: UIButton!
    
    @IBOutlet weak var button3: UIButton!
    
    var letters: Array<Character> = []
    
    
    func bubbleLetters() {
        let firstRow = ["K","E","L","İ","M","E","Y","İ"]
        let secondRow = ["B","U","L"]
        
        let firstStack = createLetterStackView(letters: firstRow)
        let secondStack = createLetterStackView(letters: secondRow)
        
        let verticalStack = UIStackView(arrangedSubviews: [firstStack, secondStack])
        verticalStack.axis = .vertical
        verticalStack.spacing = 8
        verticalStack.alignment = .center
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(verticalStack)
       
        NSLayoutConstraint.activate([
              verticalStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
              verticalStack.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -150),
              verticalStack.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.9)
          ])
    }
    
    func createLetterStackView(letters: [String]) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.alignment = .center

        for letter in letters {
            let label = UILabel()
            label.text = letter
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
            label.textColor = .black
            label.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
            label.layer.cornerRadius = 20
            label.layer.masksToBounds = false
            label.layer.shadowColor = UIColor.black.cgColor
            label.layer.shadowOpacity = 0.3
            label.layer.shadowOffset = CGSize(width: 2, height: 2)
            label.layer.shadowRadius = 4
            label.layer.borderWidth = 0

            label.widthAnchor.constraint(equalToConstant: 40).isActive = true
            label.heightAnchor.constraint(equalToConstant: 40).isActive = true

            stackView.addArrangedSubview(label)
        }

        return stackView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIHelper.setBackGroundColor(for:view)
        UIHelper.setButtons([button1,button2,button3])
        UIHelper.animateButtons([button1,button2,button3])
        
        bubbleLetters() 
    }
}
