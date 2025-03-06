//
//  GameScore.swift
//  kelimeOyunu
//
//  Created by ceyda oymak on 26.10.2024.
//

import Foundation

class GameScore{
    static let shared = GameScore()
    
    private(set) var score=0
    
    private init() {}
    
    func increseScore(by points: Int){
        score+=points
    }
    
    func decreaseScore(by points: Int){
        score-=points
    }
    
    func resetScore(){
        score = 0
    }
    
}
