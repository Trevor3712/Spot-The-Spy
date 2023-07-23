//
//  Constants.swift
//  Spot The Spy
//
//  Created by 楊哲維 on 2023/7/22.
//

import Foundation

enum SoundConstant {
    static let click = "click_se"
    static let profile = "profile_se"
    static let play = "play_se"
    static let record = "record_se"
    static let editing = "editing_se"
    static let gunLoaded = "gunLoaded_se"
    static let main = "main_bgm"
    static let victory = "victory_bgm"
    static let vote = "vote_long_bgm"
    static let gunShot = "gunShot_se"
    static let wav = "wav"
}

enum FirestoreConstans {
    static let rooms = "Rooms"
    static let roomId = "roomId"
    static let users = "Users"
    static let userEmail = "userEmail"
    static let name = "name"
    static let voted = "voted"
    static let playersReady = "playersReady"
    static let clue = "clue"
    static let identities = "identities"
    static let message = "message"
    static let player = "player"
    static let playerIndex = "playerIndex"
    static let playerNumber = "playerNumber"
    static let prompts = "prompts"
    static let normalPrompt = "normalPrompt"
    static let spyPrompt = "spyPrompt"
    static let isSpyWin = "isSpyWin"
}

// UD equals to UserDefaults
enum UDConstants {
    static let roomId = "roomId"
    static let userEmail = "userEmail"
    static let userName = "userName"
    static let playerIdentity = "playerIdentity"
    static let hostPrompt = "hostPrompt"
    static let playerPrompt = "playerPrompt"
    static let playersArray = "playersArray"
}
