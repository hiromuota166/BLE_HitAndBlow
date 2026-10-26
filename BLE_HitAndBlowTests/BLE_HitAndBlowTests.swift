//
//  BLE_HitAndBlowTests.swift
//  BLE_HitAndBlowTests
//
//  Created by 太田啓夢 on 2026/10/01.
//

import Testing
@testable import BLE_HitAndBlow

struct BLE_HitAndBlowTests {
    @Test("結果返却が正しいか", arguments: [
        ([5,2,4], GuessResult(hit: 3, blow: 0)),
        ([0,9,1], GuessResult(hit: 0, blow: 0)),
        ([5,4,2], GuessResult(hit: 1, blow: 2)),
    ])
    func result(guesses: [Int], expected: GuessResult) throws {
        let ans = try Code([5,2,4])
        let logic = GameLogic()
        
        let result = logic.gameResult(ans: ans, guesses: try Code(guesses))
        
        #expect(result == expected)
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
