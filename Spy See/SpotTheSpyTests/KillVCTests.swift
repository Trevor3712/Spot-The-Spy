//
//  SpotTheSpyTests.swift
//  SpotTheSpyTests
//
//  Created by 楊哲維 on 2023/7/23.
//

import XCTest
@testable import Spot_The_Spy

final class KillVCTests: XCTestCase {
    var killVC: KillViewController?

    override func setUp() {
        super.setUp()
        killVC = KillViewController()
    }

    override func tearDown() {
        killVC = nil
        super.tearDown()
    }
    func testKillWhichPlayer_tied() {
        killVC?.playersArray = ["player1", "player2", "player3"]
        killVC?.votedArray = [
            ["player1": "player2"],
            ["player2": "player3"],
            ["player3": "player1"]
        ]
        let selectedPlayer = killVC?.killWhichPlayer().selectedPlayer
        let selectedIndex = killVC?.killWhichPlayer().selectedIndex
        XCTAssertEqual(selectedPlayer, "player1")
        XCTAssertEqual(selectedIndex, 0)
    }
    func testKillWhichPlayer_noTied() {
        killVC?.playersArray = ["player1", "player2", "player3"]
        killVC?.votedArray = [
            ["player1": "player2"],
            ["player2": "player3"],
            ["player3": "player2"]
        ]
        let selectedPlayer = killVC?.killWhichPlayer().selectedPlayer
        let selectedIndex = killVC?.killWhichPlayer().selectedIndex
        XCTAssertEqual(selectedPlayer, "player2")
        XCTAssertEqual(selectedIndex, 1)
    }
}
