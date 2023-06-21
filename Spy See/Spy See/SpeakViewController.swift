//
//  SpeakViewController.swift
//  Spy See
//
//  Created by 楊哲維 on 2023/6/17.
//

import UIKit
import FirebaseFirestore
import AVFoundation

class SpeakViewController: UIViewController {
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var clueLabel: UILabel!
    @IBOutlet weak var clueTextView: UITextView!
    @IBOutlet weak var speakButton: UIButton!
    var players: [String] = []
    var currentPlayerIndex: Int = 0
//    var initialPlayerIndex: Int = 0
    var timer: Timer?
    let dataBase = Firestore.firestore()
    var audioRecoder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?
    var fileName: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        if let storedPlayers = UserDefaults.standard.stringArray(forKey: "playersArray") {
            players = storedPlayers
        }
//        currentPlayerIndex = Int.random(in: 0..<players.count)
//        initialPlayerIndex = currentPlayerIndex
        showNextPrompt()
        showClue()
        configRecordSession()
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(speakButtonPressed))
        longPressRecognizer.minimumPressDuration = 0.5
        speakButton.addGestureRecognizer(longPressRecognizer)
    }
    func showNextPrompt() {
    guard currentPlayerIndex < players.count else {
        return
    }
    promptLabel.text = "\(players[currentPlayerIndex])請發言"
    currentPlayerIndex += 1
    print(currentPlayerIndex)
    if currentPlayerIndex == players.count {
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { [weak self] _ in
            self?.performSegue(withIdentifier: "SpeakToVote", sender: self)
            self?.timer?.invalidate()
        }
        return
    }
//        if currentPlayerIndex >= players.count {
//            currentPlayerIndex = 0
//        }
    timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { [weak self] _ in
        self?.showNextPrompt()
    }
}
    @IBAction func giveClue(_ sender: UIButton) {
        let room = dataBase.collection("Rooms")
        let roomId = UserDefaults.standard.string(forKey: "roomId") ?? ""
        let documentRef = room.document(roomId)
        let data: [String: Any] = [
            "clue": clueTextView.text ?? ""
        ]
        documentRef.updateData(data) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Document added successfully")
                self.clueTextView.text = ""
            }
        }
    }
    func showClue() {
        let room = dataBase.collection("Rooms")
        let roomId = UserDefaults.standard.string(forKey: "roomId") ?? ""
        let documentRef = room.document(roomId)
        documentRef.addSnapshotListener { (documentSnapshot, error) in
            if let error = error {
                print(error)
                return
            }
            guard let data = documentSnapshot?.data() else {
                print("No data available")
                return
            }
            if let clue = data["clue"] as? String {
                DispatchQueue.main.async {
                    self.clueLabel.text = clue
                    
                }
            } else {
                DispatchQueue.main.async {
                    self.clueLabel.text = ""
                }
            }
        }
    }
    @objc func speakButtonPressed() {
        guard audioRecoder == nil else {
            audioRecoder?.stop()
            audioRecoder = nil
            return
        }
        fileName = UUID().uuidString
        let destinationUrl = getDirectoryPath().appendingPathComponent("\(fileName).m4a")
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey:
                AVAudioQuality.high.rawValue
        ]
        do {
            audioRecoder = try AVAudioRecorder(url: destinationUrl, settings: settings)
            audioRecoder?.record()
        } catch {
            print("Record error:", error.localizedDescription)
        }
    }
    func getDirectoryPath() -> URL {
        let fileDiretoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return fileDiretoryURL
    }
    func configRecordSession() {
        do {
            let recordingSession = AVAudioSession.sharedInstance()
            try recordingSession.setCategory(AVAudioSession.Category.playAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission { permissionAllowed in
                if permissionAllowed {
                    // 可以開始錄音
                } else {
                    // 無法錄音，處理錯誤情況
                }
            }
        } catch {
            print("Session error:", error.localizedDescription)
        }
    }
    @IBAction func playSound(_ sender: UIButton) {
        let recordFilePath = getDirectoryPath().appendingPathComponent("\(fileName).m4a")
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: recordFilePath)
            audioPlayer?.volume = 1.0
            audioPlayer?.play()
        } catch {
            print("Play error", error.localizedDescription)
        }
    }
}
extension SpeakViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SpeakToVote" {
        }
    }
}
