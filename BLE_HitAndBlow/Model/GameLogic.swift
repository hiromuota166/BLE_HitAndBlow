//
//  GameLogic.swift
//  BLE_HitAndBlow
//
//  Created by 太田啓夢 on 2026/10/22.
//
import Playgrounds

class GameLogic {
    let gameLevel: Int = 3
    func gameResult(ans: [Int], guesses: [Int])-> GuessResult? {
        guard isValid(ans) && isValid(guesses) else { return nil }
        var hit = 0
        var blow = 0
        for (index, guess) in guesses.enumerated() {
            if ans[index] == guess {
                hit += 1
            } else if ans.contains(guess){
                blow += 1
            }
        }
        return GuessResult(hit: hit, blow: blow)
    }
    
    func isValid (_ digits: [Int]) -> Bool {
        digits.count == gameLevel && Set(digits).count == digits.count && digits.allSatisfy({ (0...9).contains($0) })
    }
}

#Playground {
    let logic = GameLogic()
    let r = logic.gameResult(ans: [10,2,4], guesses: [2,0,4])
}
