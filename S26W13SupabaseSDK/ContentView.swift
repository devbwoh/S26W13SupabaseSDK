import SwiftUI
import Supabase

struct Song: Identifiable, Decodable, Hashable {
    let id: UUID
    let title: String
    let artist: String
    let rating: Int
    let lyrics: String
}

struct ContentView: View {
    @State private var songs: [Song] = []
    @State private var isLoggedIn = false

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

#Preview {
    ContentView()
}
