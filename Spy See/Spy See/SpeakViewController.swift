//
//  SpeakViewController.swift
//  Spy See
//
//  Created by 楊哲維 on 2023/6/17.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
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
    var audioUrl: URL?
    var audioUrlFromFS: URL?
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
            }
//            if let audioClueString = data["audioClue"] as? String, let audioClue = URL(string: audioClueString) {
//                print("audio clue:\(audioClue)")
//                DispatchQueue.main.async {
//                    do {
//                        self.audioPlayer = try AVAudioPlayer(contentsOf: audioClue, fileTypeHint: AVFileType.m4a.rawValue)
//                        self.audioPlayer?.volume = 1.0
//                        self.audioPlayer?.prepareToPlay()
//                        self.audioPlayer?.play()
//                        print("play audio")
//                    } catch {
//                        print("Play error", error.localizedDescription)
//                        print("Play error: \(error)")
//                    }
//                }
//            }
            else {
                DispatchQueue.main.async {
                    self.clueLabel.text = ""
                }
            }
        }
    }
    //MARK: - Audio Record
    @IBAction func speakButtonPressed(_ sender: UIButton) {
        if audioEngine.isRunning {
           audioEngine.stop()
           recognitionRequest?.endAudio()
           speakButton.isEnabled = false
           clueTextView.text = ""
           uploadAudio(audioURL: audioUrl!) { result in
               switch result {
               case .success(let url):
                   print(url)
                   let room = self.dataBase.collection("Rooms")
                   let roomId = UserDefaults.standard.string(forKey: "roomId") ?? ""
                   let documentRef = room.document(roomId)
                   let data: [String: Any] = [
                       "audioClue": url.absoluteString
                   ]
                   documentRef.updateData(data) { error in
                       if let error = error {
                           print("Error adding document: \(error)")
                       } else {
                           print("Document added successfully")
                           print("upload local audioUrl:\(url)")
                       }
                   }
               case .failure(let error):
                  print(error)
               }
           }
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
        let destinationUrl = getDirectoryPath().appendingPathComponent("\(fileName ?? "").m4a")
        audioUrl = destinationUrl
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderBitRateKey: 128000,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
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
        print("pressed")
        let recordFilePath = getDirectoryPath().appendingPathComponent("\(fileName ?? "").m4a")
        let audioFileURL = URL(fileURLWithPath: recordFilePath.path)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: audioFileURL)
                audioPlayer?.volume = 1.0
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
                print(recordFilePath)
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
    //MARK: - Speech Recognize
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
    //MARK: - Upload audio and play
    func uploadAudio(audioURL: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        let fileReference = Storage.storage().reference().child("\(fileName ?? "").m4a")
        if let data = try? Data(contentsOf: audioURL) {
            fileReference.putData(data, metadata: nil) { result in
                switch result {
                case .success(_):
                    fileReference.downloadURL { url, error in
                        if let downloadURL = url {
                            self.audioUrlFromFS = downloadURL
                            print("audioUrlFromFS:\(self.audioUrlFromFS)")
                            completion(.success(downloadURL))
                        } else if let error = error {
                            completion(.failure(error))
                        }
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
}
extension SpeakViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SpeakToVote" {
        }
    }
}
