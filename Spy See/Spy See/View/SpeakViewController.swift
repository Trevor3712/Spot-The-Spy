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
    lazy var messageTextField: BaseTextField = {
        let messageTextField = BaseTextField()
        messageTextField.placeholder = "在這裡輸入文字"
        messageTextField.delegate = self
        return messageTextField
    }()
    private lazy var sendButton1: UIButton = {
        let sendButton1 = UIButton()
        sendButton1.setBackgroundImage(UIImage(systemName: SystemImageConstants.paperplaneFill), for: .normal)
        sendButton1.setBackgroundImage(UIImage(systemName: SystemImageConstants.paperplane), for: .highlighted)
        sendButton1.tintColor = .B4
        sendButton1.addTarget(self, action: #selector(sendClue), for: .touchUpInside)
        return sendButton1
    }()
    private lazy var sendButton2: UIButton = {
        let sendButton2 = UIButton()
        sendButton2.setBackgroundImage(UIImage(systemName: SystemImageConstants.paperplaneFill), for: .normal)
        sendButton2.setBackgroundImage(UIImage(systemName: SystemImageConstants.paperplane), for: .highlighted)
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
        timeImageView.image = UIImage(systemName: SystemImageConstants.hourglass)
        timeImageView.tintColor = .B4
        return timeImageView
    }()
    lazy var speakButton1: UIButton = {
        let speakButton1 = UIButton()
        speakButton1.setBackgroundImage(UIImage(systemName: SystemImageConstants.micFill), for: .normal)
        speakButton1.tintColor = .B4
        speakButton1.addTarget(self, action: #selector(recordAudioClue), for: .touchUpInside)
        return speakButton1
    }()
    lazy var speakButton2: UIButton = {
        let speakButton2 = UIButton()
        speakButton2.setBackgroundImage(UIImage(systemName: SystemImageConstants.micFill), for: .normal)
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
    private let userName = UserDefaults.standard.string(forKey: UDConstants.userName)
    private var players: [String] = []
    private var currentPlayerIndex: Int = 0
    private var timer: Timer?
    var audioRecoder: AVAudioRecorder?
    private var countdown = 7
    var clues: [String] = []
    var messages: [String] = []
    private var documentListener: ListenerRegistration?
    var isButtonPressed = false
    let audioSession = AVAudioSession.sharedInstance()
    let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "zh-TW"))
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    var audioEngine = AVAudioEngine()
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
        if let storedPlayers = UserDefaults.standard.stringArray(forKey: UDConstants.playersArray) {
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
            setExitPageState()
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
        progressView.setProgress(1, animated: true)
        setTimer()
    }
    private func setExitPageState() {
        currentPlayerIndex = 0
        documentListener?.remove()
        clues = []
        messages = []
    }
    private func setTimer() {
        countdown = 7
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
            FirestoreConstans.clue: FieldValue.arrayUnion(["\(userName ?? "") : \(messageTextField.text ?? "")"])
        ]
        FirestoreManager.shared.updateData(data: data) {
            self.messageTextField.text = ""
        }
    }
    @objc private func sendMesssge() {
        playSeAudio()
        vibrate()
        let data: [String: Any] = [
            FirestoreConstans.message: FieldValue.arrayUnion(["\(userName ?? "") : \(messageTextField.text ?? "")"])
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
                if let clue = document[FirestoreConstans.clue] as? [String] {
                    clues = []
                    clues.append(contentsOf: clue)
                    if !clues.isEmpty {
                        clueTableView.reloadData()
                        let lastRow = clueTableView.numberOfRows(inSection: 0) - 1
                        let indexPath = IndexPath(row: lastRow, section: 0)
                        clueTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                    }
                }
                if let message = document[FirestoreConstans.message] as? [String] {
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
        if players[currentPlayerIndex] == UserDefaults.standard.string(forKey: UDConstants.userName) {
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
    private func deleteMessage() {
        // swiftlint:disable array_constructor
        let data: [String: Any] = [
            FirestoreConstans.clue: [String](),
            FirestoreConstans.message: [String]()
        ]
        // swiftlint:enable array_constructor
        FirestoreManager.shared.updateData(data: data)
    }
}
// swiftlint:enable type_body_length
