import Foundation

@Observable
@MainActor
final class SongViewModel {
    // MARK: - Properties
    private var _songs: [Song] = []
    var songs: [Song] { _songs }

    private(set) var isLoggedIn = false

    var isLoading = false
    var errorMessage: String?

    private let repository: SongRepository

    init(_ repository: SongRepository? = nil) {
        self.repository = repository ?? MemorySongRepository()
    }

    // MARK: - Auth Actions
    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            try await repository.signIn(email: email, password: password)
            isLoggedIn = true
            await fetchSongs()
        } catch {
            errorMessage = "로그인 실패: \(error.localizedDescription)"
        }
    }

    func signOut() async {
        do {
            try await repository.signOut()
            isLoggedIn = false
            _songs = []
        } catch {
            errorMessage = "로그아웃 실패: \(error.localizedDescription)"
        }
    }

    // MARK: - CRUD Actions
    func fetchSongs() async {
        guard isLoggedIn else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            _songs = try await repository.fetchSongs()
        } catch {
            errorMessage = "데이터 조회 실패: \(error.localizedDescription)"
        }
    }

    func addSong(title: String, artist: String, rating: Int, lyrics: String) async {
        guard isLoggedIn else { return }
        let newSong = NewSong(title: title, artist: artist, rating: rating, lyrics: lyrics)

        do {
            try await repository.addSong(newSong)
            await fetchSongs()
        } catch {
            errorMessage = "노래 추가 실패: \(error.localizedDescription)"
        }
    }

    func deleteSong(_ song: Song) async {
        guard isLoggedIn else { return }

        do {
            try await repository.deleteSong(id: song.id)
            await fetchSongs()
        } catch {
            errorMessage = "노래 삭제 실패: \(error.localizedDescription)"
        }
    }
}
