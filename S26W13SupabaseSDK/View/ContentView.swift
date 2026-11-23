import SwiftUI

struct ContentView: View {
    @State private var viewModel: SongViewModel

    @MainActor
    init(viewModel: SongViewModel? = nil) {
        _viewModel = State(initialValue: viewModel ?? SongViewModel())
//        _viewModel = State(initialValue: viewModel ?? SongViewModel(SupabaseSongRepository()))
    }

    @State private var isShowingAddSheet = false

    var body: some View {
        NavigationStack {
            if viewModel.isLoading && viewModel.songs.isEmpty {
                ProgressView("불러오는 중...")
            } else {
                List {
                    ForEach(viewModel.songs) { song in
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
                                    await viewModel.deleteSong(song)
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
                        Button(viewModel.isLoggedIn ? "로그아웃" : "임꺽정 로그인") {
                            Task {
                                if viewModel.isLoggedIn {
                                    await viewModel.signOut()
                                } else {
                                    await viewModel.signIn(email: "kjlim@test.com", password: "pass123")
                                }
                            }
                        }
                    }
                    if viewModel.isLoggedIn {
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
                    AddSongView { title, artist, rating, lyrics in
                        Task {
                            await viewModel.addSong(
                                title: title,
                                artist: artist,
                                rating: rating,
                                lyrics: lyrics
                            )
                        }
                    }
                }
                .overlay(alignment: .bottom) {
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(.white)
                            .padding(8)
                            .background(Color.red.cornerRadius(8))
                            .padding()
                    }
                }
                .refreshable {
                    await viewModel.fetchSongs()
                }
            }
        }
    }
}

#Preview("Supabase SDK 연동") {
    ContentView(viewModel: SongViewModel(SupabaseSongRepository()))
}

#Preview("Memory 데이터 테스트") {
    ContentView(viewModel: SongViewModel(MemorySongRepository()))
}
