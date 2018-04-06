//
//  ViewController.swift
//  AudioRecorder
//
//  Created by Hills, Dennis on 4/5/18.
//  Copyright © 2018 Hills, Dennis. All rights reserved.
//
//  Source: https://www.hackingwithswift.com/example-code/media/how-to-record-audio-using-avaudiorecorder
//  Plist Requirement for microphone use:
//  <key>NSMicrophoneUsageDescription</key>
//  <string>To record your beautiful voice</string>
//

import UIKit
import AVFoundation
import AVKit

class ViewController: UIViewController, AVAudioRecorderDelegate {

    // Properties
    var recordButton: UIButton!
    var recordingSesstion: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recordingSesstion = AVAudioSession.sharedInstance()
        
        // Request permission, if granted, display recording button text
        do {
            
            try recordingSesstion.setCategory(AVAudioSessionCategoryPlayAndRecord, with: AVAudioSessionCategoryOptions.defaultToSpeaker)
            try recordingSesstion.setActive(true)
            recordingSesstion.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.loadRecordingUI()
                    } else {
                        print("oooh. Failed to record audio.")
                    }
                }
            }
        } catch  {
            // failed to record
            print("Exception")
        }
    }
    
    @objc func recordTapped() {
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }

    // Building the UI through code
    func loadRecordingUI() {
        recordButton = UIButton(frame: CGRect(x: 50, y: 128, width: 280, height: 160))
        recordButton.setTitle("Tap to Record", for: .normal)
        recordButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.title1)
        recordButton.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
        view.addSubview(recordButton)
    }
    
    // Start Recording
    // Description: specify location to store the audio, configure the recording settings, then start recording
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("myrecording.m4a")
        
        let settings = [
            AVFormatIDKey : kAudioFormatAppleLossless,
            AVSampleRateKey : 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue
        ] as [String : Any]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.prepareToRecord() // Optional if you want recording to start as quickly as possible upons calling record()
            audioRecorder.record()
            recordButton.setTitle("Tap to Stop", for: .normal)
        } catch {
            finishRecording(success: false)
        }
    }
    
    // Stop Recording
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        
        if success {
            recordButton.setTitle("Tap to Re-record", for: .normal)
            playAudio(audioURL: getDocumentsDirectory().appendingPathComponent("myrecording.m4a"))
            
        } else {
            recordButton.setTitle("Tap to Record", for: .normal)
            // recording failed :(
        }
    }
    
    // Play audio/video using the AVKit
    func playAudio(audioURL: URL) {
        let player = AVPlayer(url: audioURL)
        let vc = AVPlayerViewController()
        vc.player = player

        present(vc, animated: true) {
            vc.player?.play()
        }
    }
    
    // This is called if the recording gets interrupted by the OS or if you set the forDuration: when calling .record
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    // Helper method for getting the application directory path to store the audio file
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

