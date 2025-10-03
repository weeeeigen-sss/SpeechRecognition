//
//  SpeechRecognitionApp.swift
//  SpeechRecognition
//
//  Created by Eigen, Yusaku (SSS) on 2025/09/29.
//

import SwiftUI

@main
struct SpeechRecognitionApp: App
{
    @StateObject private var store = WordStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
