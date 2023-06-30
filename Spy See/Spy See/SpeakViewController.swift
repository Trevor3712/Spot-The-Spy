//
//  SpeakViewController.swift
//  Spy See
//
//  Created by 楊哲維 on 2023/6/17.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import AVFoundation
import Speech
// swiftlint:disable type_body_length
class SpeakViewController: BaseViewController, SFSpeechRecognizerDelegate {
    
    lazy var playerLabel: UILabel = {
        let playerLabel = UILabel()
        return playerLabel
    }()
    lazy var speakLabel: UILabel = {
        let speakLabel = UILabel()
        speakLabel.attributedText = UIFont.fontStyle(
            font: .regular,
            title: "請發言",
            size: 20,
            textColor: .B2 ?? .black,
            letterSpacing: 10)
        return speakLabel
    }()
    lazy var clueTableView: BaseMessageTableView = {
        let clueTableView = BaseMessageTableView()
        clueTableView.layer.borderColor = UIColor.white.cgColor
        clueTableView.backgroundColor = .B1
        clueTableView.register(MessageHeaderView.self, forHeaderFooterViewReuseIdentifier: MessageHeaderView.reuseIdentifier)
        clueTableView.register(MessageCell.self, forCellReuseIdentifier: MessageCell.reuseIdentifier)
        clueTableView.dataSource = self
        clueTableView.delegate = self
        clueTableView.tag = 1
        return clueTableView
    }()
    lazy var messageTableView: BaseMessageTableView = {
        let messageTableView = BaseMessageTableView()
        messageTableView.register(MessageHeaderView.self, forHeaderFooterViewReuseIdentifier: MessageHeaderView.reuseIdentifier)
        messageTableView.register(MessageCell.self, forCellReuseIdentifier: MessageCell.reuseIdentifier)
        messageTableView.dataSource = self
        messageTableView.delegate = self
        messageTableView.tag = 2
        return messageTableView
    }()
    lazy var clueTextField: BaseTextField = {
        let clueTextField = BaseTextField()
        clueTextField.placeholder = "線索輸入區"
        clueTextField.backgroundColor = .B3
        return clueTextField
    }()
    lazy var messageTextField: BaseTextField = {
        let messageTextField = BaseTextField()
        messageTextField.placeholder = "討論輸入區"
        messageTextField.backgroundColor = .B3
        return messageTextField
    }()
    lazy var sendButton1: UIButton = {
        let sendButton1 = UIButton()
        sendButton1.setBackgroundImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        sendButton1.tintColor = .B4
        sendButton1.addTarget(self, action: #selector(sendClue), for: .touchUpInside)
        return sendButton1
    }()
    lazy var sendButton2: UIButton = {
        let sendButton2 = UIButton()
        sendButton2.setBackgroundImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        sendButton2.tintColor = .B4
        sendButton2.addTarget(self, action: #selector(sendMesssge), for: .touchUpInside)
        return sendButton2
    }()
    lazy var progressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.progressViewStyle = .default
        progressView.progressTintColor = .Y
        progressView.trackTintColor = .white
        progressView.setProgress(1, animated: false)
        return progressView
    }()
    lazy var timeImageView: UIImageView = {
        let timeImageView = UIImageView()
        timeImageView.image = UIImage(systemName: "hourglass")
        timeImageView.tintColor = .B4
        return timeImageView
    }()
    lazy var speakButton1: UIButton = {
        let speakButton1 = UIButton()
        speakButton1.setBackgroundImage(UIImage(systemName: "mic.fill"), for: .normal)
        speakButton1.tintColor = .B4
        speakButton1.addTarget(self, action: #selector(recordAudioClue), for: .touchUpInside)
//        speakButton1.addTarget(self, action: #selector(sendClue), for: .touchUpInside)
        return speakButton1
    }()
    lazy var speakButton2: UIButton = {
        let speakButton2 = UIButton()
        speakButton2.setImage(UIImage(systemName: "mic.fill"), for: .normal)
        speakButton2.tintColor = .B4
//        speakButton2.addTarget(self, action: #selector(speakButton2Pressed), for: .touchUpInside)
        return speakButton2
    }()
    let userName = UserDefaults.standard.string(forKey: "userName")
    var players: [String] = []
    var currentPlayerIndex: Int = 0
    var timer: Timer?
    let dataBase = Firestore.firestore()
    var audioRecoder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?
    var fileName: String?
    var audioUrl: URL?
    var audioUrlFromFS: URL?
    var countdown = 10
    var clues: [String] = []
    var messages: [String] = []
    var listener: ListenerRegistration?
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "zh-TW"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    override func viewDidLoad() {
        super.viewDidLoad()
        [playerLabel, speakLabel,
         clueTableView, messageTableView,
         clueTextField, messageTextField,
         sendButton1, sendButton2,
         progressView, timeImageView,
         speakButton1, speakButton2].forEach { view.addSubview($0) }
        playerLabel.snp.makeConstraints { make in
            make.top.equalTo(view).offset(60)
            make.centerX.equalTo(view)
        }
        speakLabel.snp.makeConstraints { make in
            make.top.equalTo(playerLabel.snp.bottom)
            make.centerX.equalTo(view)
        }
        clueTableView.snp.makeConstraints { make in
            make.top.equalTo(speakLabel.snp.bottom).offset(20)
            make.left.right.equalTo(view).inset(30)
            make.height.equalTo(240)
        }
        messageTableView.snp.makeConstraints { make in
            make.top.equalTo(clueTableView.snp.bottom).offset(24)
            make.left.right.equalTo(view).inset(30)
            make.height.equalTo(240)
        }
        progressView.snp.makeConstraints { make in
            make.top.equalTo(messageTableView.snp.bottom).offset(24)
            make.left.equalTo(messageTableView)
            make.width.equalTo(280)
            make.height.equalTo(12)
        }
        timeImageView.snp.makeConstraints { make in
            make.centerY.equalTo(progressView)
            make.centerX.equalTo(sendButton2)
            make.width.height.equalTo(24)
        }
        messageTextField.snp.makeConstraints { make in
            make.top.equalTo(progressView.snp.bottom).offset(24)
            make.left.equalTo(progressView)
            make.width.equalTo(250)
            make.height.equalTo(40)
        }
        sendButton1.snp.makeConstraints { make in
            make.centerY.equalTo(messageTextField)
            make.left.equalTo(messageTextField.snp.right).offset(12)
            make.width.height.equalTo(40)
        }
        speakButton1.snp.makeConstraints { make in
            make.centerY.equalTo(sendButton1)
            make.left.equalTo(sendButton1.snp.right).offset(8)
            make.width.height.equalTo(40)
        }
//        speakButton2.snp.makeConstraints { make in
//            make.centerY.equalTo(sendButton2)
//            make.left.equalTo(sendButton2.snp.right).offset(12)
//        }
//        clueTextField.snp.makeConstraints { make in
//            make.top.equalTo(speakButton2.snp.bottom).offset(12)
//            make.left.equalTo(messageTableView)
//            make.width.equalTo(250)
//            make.height.equalTo(40)
//        }
//        sendButton2.snp.makeConstraints { make in
//            make.centerX.equalTo(sendButton1)
//            make.top.equalTo(sendButton1.snp.right).offset(12)
//            make.width.height.equalTo(40)
//        }
        configRecordSession()
        speechAuth()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let storedPlayers = UserDefaults.standard.stringArray(forKey: "playersArray") {
            players = storedPlayers
        }
        showClue()
        showNextPlayer()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        deleteMessage()
    }
    func showNextPlayer() {
        guard currentPlayerIndex < players.count else {
            let voteVC = VoteViewController()
            currentPlayerIndex = 0
            listener?.remove()
            clues = []
            messages = []
            clueTableView.reloadData()
            messageTableView.reloadData()
            navigationController?.pushViewController(voteVC, animated: true)
            return
        }
        toggleButton()
        playerLabel.attributedText = UIFont.fontStyle(
            font: .semibold,
            title: "\(players[currentPlayerIndex])",
            size: 35,
            textColor: .B2 ?? .black,
            letterSpacing: 10)
        countdown = 10
        progressView.setProgress(1, animated: false)
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
    }
    @objc func updateProgress() {
        countdown -= 1
        let progress = Float(countdown) / Float(10)
        progressView.setProgress(progress, animated: true)
        if countdown <= 0 {
            timer?.invalidate()
            currentPlayerIndex += 1
            showNextPlayer()
        }
    }
    @objc func sendClue() {
        let room = dataBase.collection("Rooms")
        let roomId = UserDefaults.standard.string(forKey: "roomId") ?? ""
        let documentRef = room.document(roomId)
        let data: [String: Any] = [
            "clue": FieldValue.arrayUnion(["\(userName ?? "") : \(messageTextField.text ?? "")"])
        ]
        documentRef.updateData(data) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Document added successfully")
                self.messageTextField.text = ""
            }
        }
    }
    @objc func sendMesssge() {
        let room = dataBase.collection("Rooms")
        let roomId = UserDefaults.standard.string(forKey: "roomId") ?? ""
        let documentRef = room.document(roomId)
        let data: [String: Any] = [
            "message": FieldValue.arrayUnion(["\(userName ?? "") : \(messageTextField.text ?? "")"])
        ]
        documentRef.updateData(data) { error in
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Document added successfully")
                self.messageTextField.text = ""
            }
        }
    }
    func showClue() {
        let room = dataBase.collection("Rooms")
        let roomId = UserDefaults.standard.string(forKey: "roomId") ?? ""
        let documentRef = room.document(roomId)
        listener = documentRef.addSnapshotListener { (documentSnapshot, error) in
            if let error = error {
                print(error)
                return
            }
            guard let data = documentSnapshot?.data() else {
                print("No data available")
                self.clues = []
                self.messages = []
                self.clueTableView.reloadData()
                self.messageTableView.reloadData()
                return
            }
            if let clue = data["clue"] as? [String] {
                self.clues = []
                self.clues.append(contentsOf: clue)
                if !self.clues.isEmpty {
                    self.clueTableView.reloadData()
                    let lastRow = self.clueTableView.numberOfRows(inSection: 0) - 1
                    let indexPath = IndexPath(row: lastRow, section: 0)
                    self.clueTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                }
            }
            if let message = data["message"] as? [String] {
                self.messages = []
                self.messages.append(contentsOf: message)
                if !self.messages.isEmpty {
                    self.messageTableView.reloadData()
                    let lastRow = self.messageTableView.numberOfRows(inSection: 0) - 1
                    let indexPath = IndexPath(row: lastRow, section: 0)
                    self.messageTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                }
            }
            if let audioClueString = data["audioClue"] as? String, let audioClue = URL(string: audioClueString) {
                print("audio clue:\(audioClue)")
                DispatchQueue.main.async {
                    do {
                        self.audioPlayer = try AVAudioPlayer(contentsOf: audioClue, fileTypeHint: AVFileType.m4a.rawValue)
                        self.audioPlayer?.volume = 1.0
                        self.audioPlayer?.prepareToPlay()
                        self.audioPlayer?.play()
                        print("play audio")
                    } catch {
                        print("Play error", error.localizedDescription)
                        print("Play error: \(error)")
                    }
                }
            }
        }
    }
    func toggleButton() {
        if players[currentPlayerIndex] == UserDefaults.standard.string(forKey: "userName") {
            sendButton1.isHidden = false
            speakButton1.isHidden = false
            sendButton2.isHidden = true
            speakButton2.isHidden = true
        } else {
            sendButton2.isHidden = false
            speakButton2.isHidden = false
            sendButton1.isHidden = true
            speakButton1.isHidden = true
        }
    }
    // MARK: - Audio Record
    @objc func recordAudioClue() {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            speakButton1.isEnabled = false
            messageTextField.text = ""
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
//            speakButton.setTitle("Record", for: .normal)
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
//            speakButton.setTitle("Stop", for: .normal)
        } catch {
            print("Record error:", error.localizedDescription)
        }
    }
    func playSound() {
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
    // MARK: - Speech Recognize
    func speechAuth() {
        speakButton1.isEnabled = false

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
                self.speakButton1.isEnabled = isButtonEnabled
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
                self.messageTextField.text = result?.bestTranscription.formattedString
                isFinal = (result?.isFinal)!
//                messageTextField?
            }

            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)

                self.recognitionRequest = nil
                self.recognitionTask = nil

                self.speakButton1.isEnabled = true
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
            speakButton1.isEnabled = true
        } else {
            speakButton1.isEnabled = false
        }
    }
    // MARK: - Upload audio and play
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
    func deleteMessage() {
        let room = dataBase.collection("Rooms")
        let roomId = UserDefaults.standard.string(forKey: "roomId") ?? ""
        let documentRef = room.document(roomId)
        let data: [String: Any] = [
            "clue": [],
            "message": []
        ]
        documentRef.updateData(data)
    }
}
extension SpeakViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 1 {
            return clues.count
        } else {
            return messages.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MessageCell.reuseIdentifier) as? MessageCell else {
            fatalError("Can't create cell")
        }
        if tableView.tag == 1 {
            cell.backgroundColor = .B1
            cell.titleLabel.attributedText = UIFont.fontStyle(
                font: .regular,
                title: clues[indexPath.row],
                size: 20,
                textColor: .B4 ?? .black,
                letterSpacing: 0)
            return cell
        } else {
            cell.titleLabel.attributedText = UIFont.fontStyle(
                font: .regular,
                title: messages[indexPath.row],
                size: 20,
                textColor: .B2 ?? .black,
                letterSpacing: 0)
            return cell
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        40
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: MessageHeaderView.reuseIdentifier) as? MessageHeaderView else {
            fatalError("Can't create header")
        }
        if tableView.tag == 1 {
            header.titleLabel.attributedText = UIFont.fontStyle(
                font: .semibold,
                title: "- 線索 -",
                size: 20,
                textColor: .B4 ?? .black,
                letterSpacing: 10)
            return header
        } else {
            header.titleLabel.attributedText = UIFont.fontStyle(
                font: .semibold,
                title: "- 討論 -",
                size: 20,
                textColor: .B2 ?? .black,
                letterSpacing: 10)
            return header
        }
    }
}
