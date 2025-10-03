//
//  WordStore.swift
//  SpeechRecognition
//
//  Created by eigen on 2025/10/03.
//

import SwiftUI
internal import Combine

class WordStore: ObservableObject {
    @Published var words: [String] = []
    
    private let key = "ContextualWords"
    
    init() {
        load()
    }
    
    func add(_ word: String) {
        if !words.contains(word) {
            words.append(word)
            save()
        }
    }
    
    func remove(at offsets: IndexSet) {
        words.remove(atOffsets: offsets)
        save()
    }
    
    private func save()
    {
        UserDefaults.standard.set(words, forKey: key)
    }
    
    private func load()
    {
        if let saved = UserDefaults.standard.array(forKey: key) as? [String] {
            words = saved
        }
    }
}
