//
//  UIHelper.swift
//  KelimeyiBul!
//
//  Created by ceyda oymak on 7.02.2025.
//

import UIKit

class UIHelper {
    
    static func setBackGroundColor(for view:UIView){
        
        let gradient=CAGradientLayer()
        gradient.frame=view.bounds
        gradient.colors = [
            
            UIColor(hue: 0.0, saturation: 0.0, brightness: 0.85, alpha: 0.5).cgColor,
            
            UIColor(hue: 0.619, saturation: 0.887, brightness: 0.566, alpha: 0.3).cgColor,
            
            UIColor(hue: 0.0, saturation: 0.0, brightness: 0.85, alpha: 0.5).cgColor
        ]
        
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(gradient, at: 0)
    }
    
    static func setButtons(_ buttons: [UIButton]){
        for button in buttons{
            button.layer.cornerRadius=20
            button.layer.shadowColor=UIColor.black.cgColor
            button.layer.shadowOpacity=0.5
            button.backgroundColor=UIColor(hue: 221, saturation: 0.38, brightness: 0.80, alpha: 1)
            
        }
    }
    static func label(for label: UILabel){
        
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.textAlignment = .center
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOpacity = 0.2
        label.layer.shadowOffset = CGSize(width: 1, height: 1)
        label.sizeToFit()
    }
    
    static func animateButtons(_ buttons: [UIButton]) {
        for button in buttons {
            button.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
            button.addTarget(self, action: #selector(buttonTouchUp(_:)), for: .touchUpInside)
            button.addTarget(self, action: #selector(buttonTouchUp(_:)), for: .touchDragExit)
        }
    }
    
    
    @objc static func buttonTouchDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.4, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        })
    }
    
    @objc static func buttonTouchUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.4, animations: {
            sender.transform = CGAffineTransform.identity
        })
        
    }
    static func letterBox(_ textfield: [CustomTextField]){
        for t in textfield {
            t.layer.borderWidth=3
            t.backgroundColor=UIColor.white
            t.textAlignment = .center
            t.font = UIFont.boldSystemFont(ofSize: 20)
            t.layer.shadowColor=UIColor.black.cgColor
            t.layer.shadowOpacity=0.4
            t.layer.shadowRadius=3
        }
    }
}
