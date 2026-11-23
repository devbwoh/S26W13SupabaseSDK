import SwiftUI

struct AddSongView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var artist = ""
    @State private var rating = 5
    @State private var lyrics = ""

    let onAdd: (String, String, Int, String) -> Void

    var body: some View {
        NavigationStack {
            Form {
                TextField("노래 제목", text: $title)
                TextField("가수", text: $artist)
                Stepper("평점: \(rating)점", value: $rating, in: 1...5)
                TextField("가사", text: $lyrics, axis: .vertical)
                    .lineLimit(3...6)
            }
            .navigationTitle("새 노래 추가")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        onAdd(title, artist, rating, lyrics)
                        dismiss()
                    }
                    .disabled(title.isEmpty || artist.isEmpty)
                }
            }
        }
    }
}
