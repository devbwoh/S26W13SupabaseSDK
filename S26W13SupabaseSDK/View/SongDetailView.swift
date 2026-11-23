import SwiftUI

struct SongDetailView: View {
    let song: Song

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HStack {
                    Text(song.artist)
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("⭐️ \(song.rating)")
                        .font(.title2)
                }
                Text(song.lyrics)
            }
            .padding()
        }
        .navigationTitle(song.title)
        .navigationBarTitleDisplayMode(.large)
    }
}
