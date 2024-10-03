//
//  NotesView.swift
//  TestGitPR
//
//  Created by JLSANCHEZP on 3/10/24.
//

import SwiftUI

struct NotesView: View {
    @State private var notes: [String] = []
    @State private var newNote: String = ""

    var body: some View {
        NavigationView {
            VStack {
                TextField("Escribe una nueva nota", text: $newNote)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button(action: {
                    addNote()
                }) {
                    Text("Añadir Nota")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                List {
                    ForEach(notes, id: \.self) { note in
                        Text(note)
                    }
                    .onDelete(perform: deleteNote)
                }
            }
            .padding()
            .navigationTitle("Notas")
        }
    }

    func addNote() {
        if !newNote.isEmpty {
            notes.append(newNote)
            newNote = ""
        }
    }

    func deleteNote(at offsets: IndexSet) {
        notes.remove(atOffsets: offsets)
    }
}

#Preview {
    NotesView()
}
