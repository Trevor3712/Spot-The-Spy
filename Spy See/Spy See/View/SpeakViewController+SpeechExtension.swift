//
//  SpeakViewController+SpeechExtension.swift
//  Spot The Spy
//
//  Created by 楊哲維 on 2023/7/23.
//

import UIKit
import Speech

extension SpeakViewController {
    @objc func recordAudioClue() {
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
    func configPlaySession() {
        do {
            try audioSession.setCategory(.playback)
            try audioSession.setActive(true)
        } catch {
            print("Session error:", error.localizedDescription)
        }
    }
    func speechAuth() {
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
    private func changeButtonStyle() {
        if isButtonPressed {
            speakButton1.setBackgroundImage(UIImage(systemName: SystemImageConstants.micFill), for: .normal)
            speakButton1.tintColor = .B4
            speakButton2.setBackgroundImage(UIImage(systemName: SystemImageConstants.micFill), for: .normal)
            speakButton2.tintColor = .B4
        } else {
            speakButton1.setBackgroundImage(UIImage(systemName: SystemImageConstants.recordCircle), for: .normal)
            speakButton1.tintColor = .R
            speakButton2.setBackgroundImage(UIImage(systemName: SystemImageConstants.recordCircle), for: .normal)
            speakButton2.tintColor = .R
        }
        isButtonPressed.toggle()
    }
}
