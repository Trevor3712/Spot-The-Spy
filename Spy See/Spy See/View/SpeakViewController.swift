//
//  SpeakViewController.swift
//  Spy See
//
//  Created by 楊哲維 on 2023/6/17.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import AVFoundation
import Speech
import AudioToolbox
// swiftlint:disable type_body_length
class SpeakViewController: BaseViewController, SFSpeechRecognizerDelegate {
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isScrollEnabled = true
        scrollView.contentSize.width = 0
        scrollView.contentSize.height = 750
        return scrollView
    }()
    private lazy var contentView = UIView()
    private lazy var playerLabel: UILabel = {
        let playerLabel = UILabel()
        return playerLabel
    }()
    private lazy var speakLabel: UILabel = {
        let speakLabel = UILabel()
        speakLabel.attributedText = UIFont.fontStyle(
            font: .regular,
            title: "請發言",
            size: 20,
            textColor: .B2 ?? .black,
            letterSpacing: 10)
        return speakLabel
    }()
    private lazy var clueTableView: BaseMessageTableView = {
        let clueTableView = BaseMessageTableView()
        clueTableView.layer.borderColor = UIColor.white.cgColor
        clueTableView.backgroundColor = .B1
        clueTableView.register(
            MessageHeaderView.self,
            forHeaderFooterViewReuseIdentifier: MessageHeaderView.reuseIdentifier
        )
        clueTableView.register(MessageCell.self, forCellReuseIdentifier: MessageCell.reuseIdentifier)
        clueTableView.dataSource = self
        clueTableView.delegate = self
        clueTableView.tag = 1
        return clueTableView
    }()
    private lazy var messageTableView: BaseMessageTableView = {
        let messageTableView = BaseMessageTableView()
        messageTableView.register(
            MessageHeaderView.self,
            forHeaderFooterViewReuseIdentifier: MessageHeaderView.reuseIdentifier
        )
        messageTableView.register(MessageCell.self, forCellReuseIdentifier: MessageCell.reuseIdentifier)
        messageTableView.dataSource = self
        messageTableView.delegate = self
        messageTableView.tag = 2
        return messageTableView
    }()
    private lazy var messageTextField: BaseTextField = {
        let messageTextField = BaseTextField()
        messageTextField.placeholder = "在這裡輸入文字"
        messageTextField.delegate = self
        return messageTextField
    }()
    private lazy var sendButton1: UIButton = {
        let sendButton1 = UIButton()
        sendButton1.setBackgroundImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        sendButton1.setBackgroundImage(UIImage(systemName: "paperplane"), for: .highlighted)
        sendButton1.tintColor = .B4
        sendButton1.addTarget(self, action: #selector(sendClue), for: .touchUpInside)
        return sendButton1
    }()
    private lazy var sendButton2: UIButton = {
        let sendButton2 = UIButton()
        sendButton2.setBackgroundImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        sendButton2.setBackgroundImage(UIImage(systemName: "paperplane"), for: .highlighted)
        sendButton2.tintColor = .B4
        sendButton2.addTarget(self, action: #selector(sendMesssge), for: .touchUpInside)
        return sendButton2
    }()
    private lazy var progressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.progressViewStyle = .default
        progressView.progressTintColor = .Y
        progressView.trackTintColor = .white
        progressView.setProgress(1, animated: false)
        return progressView
    }()
    private lazy var timeImageView: UIImageView = {
        let timeImageView = UIImageView()
        timeImageView.image = UIImage(systemName: "hourglass")
        timeImageView.tintColor = .B4
        return timeImageView
    }()
    private lazy var speakButton1: UIButton = {
        let speakButton1 = UIButton()
        speakButton1.setBackgroundImage(UIImage(systemName: "mic.fill"), for: .normal)
        speakButton1.tintColor = .B4
        speakButton1.addTarget(self, action: #selector(recordAudioClue), for: .touchUpInside)
        return speakButton1
    }()
    private lazy var speakButton2: UIButton = {
        let speakButton2 = UIButton()
        speakButton2.setBackgroundImage(UIImage(systemName: "mic.fill"), for: .normal)
        speakButton2.tintColor = .B4
        speakButton2.addTarget(self, action: #selector(recordAudioClue), for: .touchUpInside)
        return speakButton2
    }()
    private lazy var remindLabel: UILabel = {
        let remindLabel = UILabel()
        remindLabel.attributedText = UIFont.fontStyle(
            font: .light,
            title: "＊點擊麥克風開始語音辨識，再次點擊停止辨識",
            size: 15,
            textColor: .B3 ?? .black,
            letterSpacing: 0)
        return remindLabel
    }()
    private let userName = UserDefaults.standard.string(forKey: "userName")
    private var players: [String] = []
    private var currentPlayerIndex: Int = 0
    private var timer: Timer?
    private var audioRecoder: AVAudioRecorder?
    private var countdown = 7
    private var clues: [String] = []
    private var messages: [String] = []
    private var documentListener: ListenerRegistration?
    private var isButtonPressed = false
    private let audioSession = AVAudioSession.sharedInstance()
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "zh-TW"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine = AVAudioEngine()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        [playerLabel, speakLabel, clueTableView, messageTableView].forEach { contentView.addSubview($0) }
        [messageTextField, sendButton1, sendButton2, progressView].forEach { contentView.addSubview($0) }
        [timeImageView, speakButton1, speakButton2, remindLabel].forEach { contentView.addSubview($0) }
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.heightAnchor.constraint(equalToConstant: 750)
        ])
        configureLayout()
        speechAuth()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let storedPlayers = UserDefaults.standard.stringArray(forKey: "playersArray") {
            players = storedPlayers
        }
        guard let url = Bundle.main.url(forResource: SoundConstant.vote, withExtension: SoundConstant.wav) else {
            return
        }
        AudioPlayer.shared.playAudio(from: url, loop: true)
        showClue()
        showNextPlayer()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        deleteMessage()
        audioRecoder?.stop()
        audioEngine.stop()
        configPlaySession()
    }
    private func configureLayout() {
        playerLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView)
            make.centerX.equalTo(contentView)
        }
        speakLabel.snp.makeConstraints { make in
            make.top.equalTo(playerLabel.snp.bottom)
            make.centerX.equalTo(contentView)
        }
        clueTableView.snp.makeConstraints { make in
            make.top.equalTo(speakLabel.snp.bottom).offset(20)
            make.left.right.equalTo(contentView).inset(30)
            make.height.equalTo(240)
        }
        messageTableView.snp.makeConstraints { make in
            make.top.equalTo(clueTableView.snp.bottom).offset(24)
            make.left.right.equalTo(contentView).inset(30)
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
            make.centerX.equalTo(speakButton1)
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
        speakButton2.snp.makeConstraints { make in
            make.centerY.equalTo(sendButton1)
            make.left.equalTo(sendButton1.snp.right).offset(8)
            make.width.height.equalTo(40)
        }
        sendButton2.snp.makeConstraints { make in
            make.centerY.equalTo(messageTextField)
            make.left.equalTo(messageTextField.snp.right).offset(12)
            make.width.height.equalTo(40)
        }
        remindLabel.snp.makeConstraints { make in
            make.top.equalTo(messageTextField.snp.bottom).offset(12)
            make.right.equalTo(speakButton2).offset(-5)
        }
    }
    private func showNextPlayer() {
        guard currentPlayerIndex < players.count else {
            currentPlayerIndex = 0
            documentListener?.remove()
            clues = []
            messages = []
            clueTableView.reloadData()
            messageTableView.reloadData()
            let voteVC = VoteViewController()
            navigationController?.pushViewController(voteVC, animated: true)
            return
        }
        currentUserTurn()
        playerLabel.attributedText = UIFont.fontStyle(
            font: .semibold,
            title: "\(players[currentPlayerIndex])",
            size: 35,
            textColor: .B2 ?? .black,
            letterSpacing: 10)
        countdown = 7
        progressView.setProgress(1, animated: true)
        timer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(updateProgress),
            userInfo: nil,
            repeats: true
        )
    }
    @objc private func updateProgress() {
        countdown -= 1
        let progress = Float(countdown) / Float(7)
        progressView.setProgress(progress, animated: true)
        if countdown <= 0 {
            timer?.invalidate()
            currentPlayerIndex += 1
            showNextPlayer()
        }
    }
    @objc private func sendClue() {
        playSeAudio()
        vibrate()
        let data: [String: Any] = [
            "clue": FieldValue.arrayUnion(["\(userName ?? "") : \(messageTextField.text ?? "")"])
        ]
        FirestoreManager.shared.updateData(data: data) {
            self.messageTextField.text = ""
        }
    }
    @objc private func sendMesssge() {
        playSeAudio()
        vibrate()
        let data: [String: Any] = [
            "message": FieldValue.arrayUnion(["\(userName ?? "") : \(messageTextField.text ?? "")"])
        ]
        FirestoreManager.shared.updateData(data: data) { [weak self] in
            guard let self = self else { return }
            messageTextField.text = ""
        }
    }
    private func showClue() {
        documentListener = FirestoreManager.shared.addSnapShotListener { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let document):
                guard let document = document else {
                    clues = []
                    messages = []
                    clueTableView.reloadData()
                    messageTableView.reloadData()
                    return
                }
                if let clue = document["clue"] as? [String] {
                    clues = []
                    clues.append(contentsOf: clue)
                    if !clues.isEmpty {
                        clueTableView.reloadData()
                        let lastRow = clueTableView.numberOfRows(inSection: 0) - 1
                        let indexPath = IndexPath(row: lastRow, section: 0)
                        clueTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                    }
                }
                if let message = document["message"] as? [String] {
                    messages = []
                    messages.append(contentsOf: message)
                    if !messages.isEmpty {
                        messageTableView.reloadData()
                        let lastRow = self.messageTableView.numberOfRows(inSection: 0) - 1
                        let indexPath = IndexPath(row: lastRow, section: 0)
                        messageTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                    }
                }
            case .failure(let error):
                print("Error getting document:\(error)")
            }
        }
    }
    private func currentUserTurn() {
        if players[currentPlayerIndex] == UserDefaults.standard.string(forKey: "userName") {
            sendButton1.isHidden = false
            speakButton1.isHidden = false
            sendButton2.isHidden = true
            speakButton2.isHidden = true
            vibrateHard()
        } else {
            vibrate()
            sendButton2.isHidden = false
            speakButton2.isHidden = false
            sendButton1.isHidden = true
            speakButton1.isHidden = true
        }
    }
    private func changeButtonStyle() {
        if isButtonPressed {
            speakButton1.setBackgroundImage(UIImage(systemName: "mic.fill"), for: .normal)
            speakButton1.tintColor = .B4
            speakButton2.setBackgroundImage(UIImage(systemName: "mic.fill"), for: .normal)
            speakButton2.tintColor = .B4
        } else {
            speakButton1.setBackgroundImage(UIImage(systemName: "record.circle"), for: .normal)
            speakButton1.tintColor = .R
            speakButton2.setBackgroundImage(UIImage(systemName: "record.circle"), for: .normal)
            speakButton2.tintColor = .R
        }
        isButtonPressed.toggle()
    }
    // MARK: - Speech Recognize
    @objc private func recordAudioClue() {
        vibrate()
        configRecordSession()
        changeButtonStyle()
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.reset()
            recognitionRequest?.endAudio()
            speakButton1.isEnabled = false
            speakButton2.isEnabled = false
            messageTextField.text = ""
        } else {
            speechRecognize()
        }
        configPlaySession()
    }
    private func configRecordSession() {
        do {
            try audioSession.setCategory(
                .playAndRecord,
                mode: .default,
                options: [.defaultToSpeaker, .allowBluetooth])
            try audioSession.setActive(true)
        } catch {
            print("Session error:", error.localizedDescription)
        }
    }
    private func configPlaySession() {
        do {
            try audioSession.setCategory(.playback)
            try audioSession.setActive(true)
        } catch {
            print("Session error:", error.localizedDescription)
        }
    }
    private func speechAuth() {
        speakButton1.isEnabled = false
        speakButton2.isEnabled = false

        speechRecognizer?.delegate = self

        SFSpeechRecognizer.requestAuthorization { authStatus in
            var isButtonEnabled = false

            switch authStatus {
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
            @unknown default:
                fatalError("Speech unknown error")
            }

            OperationQueue.main.addOperation {
                self.speakButton1.isEnabled = isButtonEnabled
                self.speakButton2.isEnabled = isButtonEnabled
            }
        }
    }
    private func speechRecognize() {
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

        recognitionTask = speechRecognizer?.recognitionTask( with: recognitionRequest) { result, error in
            var isFinal = false
            if let result = result {
                self.messageTextField.text = result.bestTranscription.formattedString
                isFinal = result.isFinal
            }

            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)

                self.recognitionRequest = nil
                self.recognitionTask = nil

                self.speakButton1.isEnabled = true
                self.speakButton2.isEnabled = true
            }
        }
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
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
            speakButton2.isEnabled = true
        } else {
            speakButton1.isEnabled = false
            speakButton2.isEnabled = true
        }
    }
    private func deleteMessage() {
        // swiftlint:disable array_constructor
        let data: [String: Any] = [
            "clue": [String](),
            "message": [String]()
        ]
        // swiftlint:enable array_constructor
        FirestoreManager.shared.updateData(data: data)
    }
}
// swiftlint:enable type_body_length
extension SpeakViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 1 {
            return clues.count
        } else {
            return messages.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: MessageCell.reuseIdentifier) as? MessageCell else {
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
        guard let header = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: MessageHeaderView.reuseIdentifier) as? MessageHeaderView else {
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
extension SpeakViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let editingUrl = editingUrl else {
            return
        }
        playSeAudio(from: editingUrl)
    }
}
