//
//  GameLogic.swift
//  BLE_HitAndBlow
//
//  Created by 太田啓夢 on 2026/10/22.
//
import Playgrounds

enum CodeError: Error {
    case wrongLength
    case duplicated
    case outOfRange
}

struct Code {
    let digits: [Int]
    
    init(_ digits: [Int]) throws {
        guard digits.count == 3 else { throw CodeError.wrongLength }
        guard Set(digits).count == digits.count else { throw CodeError.duplicated }
        guard digits.allSatisfy({ (0...9).contains($0) }) else { throw CodeError.outOfRange }
        self.digits = digits
    }
}

class GameLogic {
    let gameLevel: Int = 3
    func gameResult(ans: Code, guesses: Code)-> GuessResult {
        var hit = 0
        var blow = 0
        for (index, guess) in guesses.digits.enumerated() {
            if ans.digits[index] == guess {
                hit += 1
            } else if ans.digits.contains(guess){
                blow += 1
            }
        }
        return GuessResult(hit: hit, blow: blow)
    }
}

#Playground {
    let logic = GameLogic()
    let r = logic.gameResult(ans: try Code([5,2,4]), guesses: try Code([2,0,4]))
}
