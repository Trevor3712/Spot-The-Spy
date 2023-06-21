//
//  SpeakViewController.swift
//  Spy See
//
//  Created by 楊哲維 on 2023/6/17.
//

import UIKit
import FirebaseFirestore
import AVFoundation
import Speech

class SpeakViewController: UIViewController, SFSpeechRecognizerDelegate {
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
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "zh-TW"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
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
        speechAuth()
    }
    func showNextPrompt() {
    guard currentPlayerIndex < players.count else {
        return
    }
    promptLabel.text = "\(players[currentPlayerIndex])請發言"
    currentPlayerIndex += 1
    print(currentPlayerIndex)
    if currentPlayerIndex == players.count {
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false) { [weak self] _ in
            self?.performSegue(withIdentifier: "SpeakToVote", sender: self)
            self?.timer?.invalidate()
        }
        return
    }
//        if currentPlayerIndex >= players.count {
//            currentPlayerIndex = 0
//        }
    timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false) { [weak self] _ in
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
    @IBAction func speakButtonPressed(_ sender: UIButton) {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            speakButton.isEnabled = false
            clueTextView.text = ""
        } else {
            speechRecognize()
        }
        guard audioRecoder == nil else {
            audioRecoder?.stop()
            audioRecoder = nil
            speakButton.setTitle("Record", for: .normal)
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
            speakButton.setTitle("Stop", for: .normal)
        } catch {
            print("Record error:", error.localizedDescription)
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
    func speechAuth() {
        speakButton.isEnabled = false

        speechRecognizer?.delegate = self

        SFSpeechRecognizer.requestAuthorization { (authStatus) in  //4

            var isButtonEnabled = false

            switch authStatus {  //5
            case .authorized:
                isButtonEnabled = true

            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")

            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")

            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }

            OperationQueue.main.addOperation() {
                self.speakButton.isEnabled = isButtonEnabled
            }
        }
    }
    func speechRecognize() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.record)
            try audioSession.setMode(AVAudioSession.Mode.measurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()

        let inputNode = audioEngine.inputNode

        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }

        recognitionRequest.shouldReportPartialResults = true

        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            var isFinal = false

            if result != nil {
                self.clueTextView.text = result?.bestTranscription.formattedString
                isFinal = (result?.isFinal)!
            }

            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)

                self.recognitionRequest = nil
                self.recognitionTask = nil

                self.speakButton.isEnabled = true
            }
        })
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()

        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
    }
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            speakButton.isEnabled = true
        } else {
            speakButton.isEnabled = false
        }
    }
}
extension SpeakViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SpeakToVote" {
        }
    }
}
