//
//  WordListView.swift
//  SpeechRecognition
//
//  Created by Eigen, Yusaku (SSS) on 2025/09/30.
//

import SwiftUI


struct WordListView: View
{
    @ObservedObject var store: WordStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var newWord: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(store.words, id: \.self) { word in
                        HStack {
                            Text(word)
                            Spacer()
                        }
                    }
                    .onDelete(perform: store.remove(at:))
                }
                
                HStack {
                    TextField("新しい単語を入力", text: $newWord)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button("追加") {
                        let trimmed = newWord.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !trimmed.isEmpty && !store.words.contains(trimmed) {
                            store.add(trimmed)
                        }
                        newWord = ""
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
            .navigationTitle("単語リスト")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完了") {
                        dismiss()
                    }
                }
            }
        }
    }
}
