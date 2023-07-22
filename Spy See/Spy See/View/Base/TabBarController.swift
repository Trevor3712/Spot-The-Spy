//
//  TabBarController.swift
//  Spot The Spy
//
//  Created by 楊哲維 on 2023/7/10.
//

import UIKit
import AVFoundation

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    private var audioPlayer: AVAudioPlayer?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let selectedIndex = tabBarController.selectedIndex
        switch selectedIndex {
        case 0:
            let url = Bundle.main.url(forResource: SoundConstant.gunLoaded, withExtension: SoundConstant.wav)
            guard let url = url else {
                return
            }
            playAudio(from: url)
        case 1:
            let url = Bundle.main.url(forResource: SoundConstant.profile, withExtension: SoundConstant.wav)
            guard let url = url else {
                return
            }
            playAudio(from: url)
        case 2:
            let url = Bundle.main.url(forResource: SoundConstant.record, withExtension: SoundConstant.wav)
            guard let url = url else {
                return
            }
            playAudio(from: url)
        default:
            let url = Bundle.main.url(forResource: SoundConstant.profile, withExtension: SoundConstant.wav)
            guard let url = url else {
                return
            }
            playAudio(from: url)
        }
    }
    private func playAudio(from url: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Failed to play audio: \(error.localizedDescription)")
        }
    }
}
