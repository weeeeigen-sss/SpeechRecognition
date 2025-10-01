//
//  WordListView.swift
//  SpeechRecognition
//
//  Created by Eigen, Yusaku (SSS) on 2025/09/30.
//

import SwiftUI


struct WordListView: View {
    @Binding var contextualStrings: [String]
    @Environment(\.dismiss) private var dismiss
    
    @State private var newWord: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(contextualStrings, id: \.self) { word in
                        HStack {
                            Text(word)
                            Spacer()
                        }
                    }
                    .onDelete { indexSet in
                        contextualStrings.remove(atOffsets: indexSet)
                    }
                }
                
                HStack {
                    TextField("新しい単語を入力", text: $newWord)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button("追加") {
                        let trimmed = newWord.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !trimmed.isEmpty && !contextualStrings.contains(trimmed) {
                            contextualStrings.append(trimmed)
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
