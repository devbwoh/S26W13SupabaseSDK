import SwiftUI
import Supabase

struct Song: Identifiable, Decodable, Hashable {
    let id: UUID
    let title: String
    let artist: String
    let rating: Int
    let lyrics: String
}

struct NewSong: Encodable {
    let title: String
    let artist: String
    let rating: Int
    let lyrics: String
}

struct ContentView: View {
    @State private var songs: [Song] = []
    @State private var isLoggedIn = false
    @State private var isShowingAddSheet = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(songs) { song in
                    NavigationLink(value: song) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(song.title)
                                .font(.headline)
                            Text(song.artist)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .swipeActions {
                        Button("삭제", role: .destructive) {
                            Task {
                                await deleteSong(song)
                            }
                        }
                    }
                }
            }
            .navigationDestination(for: Song.self) { song in
                SongDetailView(song: song)
            }
            .toolbar {
                ToolbarItem {
                    Button(isLoggedIn ? "로그아웃" : "임꺽정 로그인") {
                        Task {
                            if isLoggedIn {
                                try? await SupabaseManager.client.auth.signOut()
                                isLoggedIn = false
                                songs = []
                            } else {
                                await signInAndFetch()
                            }
                        }
                    }
                }
                
                if isLoggedIn {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            isShowingAddSheet = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $isShowingAddSheet) {
                AddSongView { newSong in
                    Task {
                        await addSong(newSong)
                    }
                }
            }
        }
    }

    func signInAndFetch() async {
        do {
            _ = try await SupabaseManager.client.auth.signIn(
                email: "kjlim@test.com",
                password: "pass123"
            )
            isLoggedIn = true
            await fetchSongs()
        } catch {
            print("로그인 실패: \(error)")
        }
    }

    func fetchSongs() async {
        do {
            songs = try await SupabaseManager.client
                .from("songs")
                .select()
                .order("created_at", ascending: false)
                .execute()
                .value
        } catch {
            print("조회 실패: \(error)")
        }
    }
    
    func deleteSong(_ song: Song) async {
        do {
            try await SupabaseManager.client
                .from("songs")
                .delete()
                .eq("id", value: song.id)
                .execute()
            await fetchSongs()
        } catch {
            print("삭제 실패: \(error)")
        }
    }
    
    func addSong(_ newSong: NewSong) async {
        do {
            try await SupabaseManager.client
                .from("songs")
                .insert(newSong)
                .execute()
            await fetchSongs()
        } catch {
            print("추가 실패: \(error)")
        }
    }
}

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

struct AddSongView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var artist = ""
    @State private var rating = 5
    @State private var lyrics = ""

    let onAdd: (NewSong) -> Void

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
                        let newSong = NewSong(
                            title: title,
                            artist: artist,
                            rating: rating,
                            lyrics: lyrics
                        )
                        onAdd(newSong)
                        dismiss()
                    }
                    .disabled(title.isEmpty || artist.isEmpty)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
