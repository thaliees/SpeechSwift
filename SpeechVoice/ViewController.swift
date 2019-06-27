//
//  ViewController.swift
//  SpeechVoice
//
//  Created by Thaliees on 6/27/19.
//  Copyright © 2019 Thaliees. All rights reserved.
//

import UIKit
import Speech

class ViewController: UIViewController, SFSpeechRecognizerDelegate {
    @IBOutlet weak var voice: UIButton!
    @IBOutlet weak var text: UILabel!
    
    // Prepare your audio content.
    private let audio = AVAudioEngine()
    // This tag informs the recognizer to perform speech recognition in a language different than the one set in the Locale.
    // In our case, use the current value
    private let speech:SFSpeechRecognizer? = SFSpeechRecognizer()
    // But if you wish to change:
    // private let speech:SFSpeechRecognizer? = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    // Create a recognition request object
    private let request = SFSpeechAudioBufferRecognitionRequest()
    // This will be used to manage, cancel, or stop the current recognition task.
    private var recognitionTask:SFSpeechRecognitionTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        speech?.delegate = self
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            OperationQueue.main.addOperation {
                switch authStatus{
                    case .notDetermined:
                        self.voice.isEnabled = false
                        self.text.text = "Speech recognition not yet authorized"
                    case .denied:
                        self.voice.isEnabled = false
                        self.text.text = "User denied access to speech recognition"
                    case .restricted:
                        self.voice.isEnabled = false
                        self.text.text = "Speech recognition restricted on this device"
                    case .authorized:
                        self.voice.isEnabled = true
                    @unknown default:
                        self.voice.isEnabled = false
                }
            }
        }
    }
    
    @IBAction func listenAction(_ sender: UIButton) {
        self.voice.isEnabled = false
        self.listen()
    }
    
    private func listen(){
        let node = audio.inputNode
        // Specify the input format
        let format = node.outputFormat(forBus: 0)
        // Remove any nus exists in the node
        node.removeTap(onBus: 0)
        // Installs an audio tap on the bus to record, monitor, and observe the output of the node
        node.installTap(onBus: 0, bufferSize: 1024, format: format) { (buffer, _) in
            self.request.append(buffer)
        }
        // Prepare for start the recognizer
        audio.prepare()
        do{
            try audio.start()
        }
        catch{
            return
        }
        recognitionTask = speech?.recognitionTask(with: request, resultHandler: { (result, error) in
            var isFinal = false
            if let result = result {
                // Format the result as a string value.
                let resultAudio = result.bestTranscription.formattedString
                self.text.text = resultAudio
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal{
                self.voice.isEnabled = true
                self.audio.stop()
                self.recognitionTask?.finish()
            }
        })
    }
}

