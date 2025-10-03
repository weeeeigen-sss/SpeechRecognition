//
//  ContentView.swift
//  SpeechRecognition
//
//  Created by Eigen, Yusaku (SSS) on 2025/09/29.
//

import SwiftUI
internal import Speech


// MARK: - ContentView
struct ContentView: View
{
    @EnvironmentObject var store: WordStore

    @StateObject private var speechRecognizer = SpeechRecognizer()
    @State private var showingWordList = false
    
    var body: some View {
        VStack {
            Text(speechRecognizer.transcript.isEmpty ? "ここに音声認識結果が表示されます" : speechRecognizer.transcript)
                .font(.title2)
                .padding()
            
            if !speechRecognizer.segments.isEmpty {
                List {
                    ForEach(speechRecognizer.segments, id: \.substringRange) { seg in
                        HStack {
                            Text(seg.substring)
                            Spacer()
                            Text("range=\(seg.substringRange)\nconfidence=\(seg.confidence)\nduration=\(seg.duration)\nalternative=\(seg.alternativeSubstrings)")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .frame(maxHeight: 400)
            }
            
            Spacer()
            
            HStack {
                Button("Start") {
                    speechRecognizer.start(locale: "ja-JP", store: store)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(10)
                
                Button("Stop") {
                    speechRecognizer.stop()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
            
            Button("追加") {
                showingWordList = true
            }
            .padding()
        }
        .sheet(isPresented: $showingWordList) {
            WordListView(store: store)
        }
    }
}
