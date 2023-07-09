//
//  AudioPlayerViewController.swift
//  Spot The Spy
//
//  Created by 楊哲維 on 2023/7/9.
//

import Foundation
import AVFoundation

class AudioPlayer {
    static let shared = AudioPlayer()
    var audioPlayer: AVAudioPlayer?
    func playAudio(from url: URL, loop: Bool = false) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = loop ? -1 : 0
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Failed to play audio: \(error.localizedDescription)")
        }
    }
    func stopAudio() {
        audioPlayer?.stop()
        audioPlayer = nil
    }
}
