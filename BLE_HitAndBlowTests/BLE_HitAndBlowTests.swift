//
//  BLE_HitAndBlowTests.swift
//  BLE_HitAndBlowTests
//
//  Created by 太田啓夢 on 2026/10/01.
//

import Testing
@testable import BLE_HitAndBlow

struct BLE_HitAndBlowTests {
    @Test("結果返却が正しいか")
    func result() {
        let ans = [5,2,4]
        let guesses = [2,0,4]
        let logic = GameLogic()
        
        let result = logic.gameResult(ans: ans, guesses: guesses)
        
        #expect(result == GuessResult(hit: 1,blow: 1))
    }

    @Test("ansが重複あり")
    func ansDuplication() throws {
        let ans = [5,5,4]
        let guesses = [2,0,4]
        let logic = GameLogic()
        
        let result = logic.gameResult(ans: ans, guesses: guesses)
        #expect(result == nil)
    }

    @Test("guessesが重複あり")
    func guessesDuplication() throws {
        let ans = [5,2,4]
        let guesses = [2,2,4]
        let logic = GameLogic()
        
        let result = logic.gameResult(ans: ans, guesses: guesses)
        #expect(result == nil)
    }
    
    @Test("ansは0~9以外許容しない")
    func ansSingleDigit() throws {
        let ans = [10,2,4]
        let guesses = [2,0,4]
        let logic = GameLogic()
        
        let result = logic.gameResult(ans: ans, guesses: guesses)
        #expect(result == nil)
    }

    @Test("guessesは0~9以外許容しない")
    func guessesSingleDigit() throws {
        let ans = [5,2,4]
        let guesses = [10,0,4]
        let logic = GameLogic()
        
        let result = logic.gameResult(ans: ans, guesses: guesses)
        #expect(result == nil)
    }
}
