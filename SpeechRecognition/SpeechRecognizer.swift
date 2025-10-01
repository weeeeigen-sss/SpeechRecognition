//
//  SpeechRecognizer.swift
//  SpeechRecognition
//
//  Created by Eigen, Yusaku (SSS) on 2025/09/30.
//

internal import Speech
internal import Combine


class SpeechRecognizer: ObservableObject {
    private var recognizer: SFSpeechRecognizer?
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    @Published var transcript: String = ""
    @Published var segments: [SFTranscriptionSegment] = []
    @Published var contextualStrings: [String] = []
    
    func start(locale: String = "ja-JP") {
        recognizer = SFSpeechRecognizer(locale: Locale(identifier: locale))
        transcript = ""
        segments = []
        
        SFSpeechRecognizer.requestAuthorization { authStatus in
            guard authStatus == .authorized else { return }
            DispatchQueue.main.async {
                self.startRecognition()
            }
        }
    }
    
    private func startRecognition() {
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try? audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        request = SFSpeechAudioBufferRecognitionRequest()
        request?.shouldReportPartialResults = true
//        request?.requiresOnDeviceRecognition = true
        request?.contextualStrings = contextualStrings
        print(request?.contextualStrings)
        
        guard let inputNode = audioEngine.inputNode as AVAudioInputNode?,
              let request = request else { return }
        
        task = recognizer?.recognitionTask(with: request) { result, error in
            if let result = result {
                DispatchQueue.main.async {
                    self.transcript = result.bestTranscription.formattedString
                    
                    if !result.isFinal
                    {
                        self.segments = result.bestTranscription.segments
//                        for segment in self.segments {
//                            print(segment)
//                        }
                    }
                }
            }
            
            if error != nil || (result?.isFinal ?? false) {
                self.stop()
            }
        }
        
        let format = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            self.request?.append(buffer)
        }
        
        audioEngine.prepare()
        try? audioEngine.start()
    }
    
    func stop() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        request?.endAudio()
        task?.cancel()
        task = nil
    }
}
