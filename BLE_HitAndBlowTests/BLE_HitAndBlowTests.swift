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
    func result() throws {
        let ans = try Code([5,2,4])
        let guesses = try Code([2,0,4])
        let logic = GameLogic()
        
        let result = logic.gameResult(ans: ans, guesses: guesses)
        
        #expect(result == GuessResult(hit: 1,blow: 1))
    }
    
    @Test("ダメな並びが適切な理由でエラーになる", arguments: [
        ([5,2], CodeError.wrongLength),
        ([5,2,4,1], CodeError.wrongLength),
        ([5,2,2], CodeError.duplicated),
        ([5,2,10], CodeError.outOfRange),
        ([5,2,-1], CodeError.outOfRange),
    ])
    func invalidCode(digits: [Int], error: CodeError) {
        #expect(throws: error) { try Code(digits) }
    }
}
