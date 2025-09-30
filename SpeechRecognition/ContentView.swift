//
//  ContentView.swift
//  SpeechRecognition
//
//  Created by Eigen, Yusaku (SSS) on 2025/09/29.
//

import SwiftUI

import Speech
internal import Combine

class SpeechRecognizer: ObservableObject
{
    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    @Published var transcript: String = ""
    
    func start() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            guard authStatus == .authorized else { return }
            
            DispatchQueue.main.async {
                self.startRecognition()
            }
        }
    }
    
    private func startRecognition() {
        transcript = ""
        
        // 既存タスクをキャンセル
        task?.cancel()
        task = nil
        
        // オーディオセッション設定
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try? audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        request = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        guard let request = request else { return }
        
        request.shouldReportPartialResults = true
        
        task = recognizer?.recognitionTask(with: request) { result, error in
            if let result = result {
                DispatchQueue.main.async {
                    self.transcript = result.bestTranscription.formattedString
                    for segment in result.bestTranscription.segments
                    {
                        print(segment)
                    }
                }
            }
            
            if error != nil || (result?.isFinal ?? false) {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.request = nil
                self.task = nil
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.request?.append(buffer)
        }
        
        audioEngine.prepare()
        try? audioEngine.start()
    }
    
    func stop() {
        audioEngine.stop()
        request?.endAudio()
        task?.cancel()
        task = nil
    }
}

struct ContentView: View {
    @StateObject private var speechRecognizer = SpeechRecognizer()
    
    var body: some View {
        VStack {
            // 上部に認識結果を表示
            Text(speechRecognizer.transcript.isEmpty ? "ここに音声認識結果が表示されます" : speechRecognizer.transcript)
                .font(.title2)
                .padding()
                .frame(maxHeight: .infinity, alignment: .top)
            
            HStack {
                Button(action: {
                    speechRecognizer.start()
                }) {
                    Text("Start")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    speechRecognizer.stop()
                }) {
                    Text("Stop")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
    }
}
