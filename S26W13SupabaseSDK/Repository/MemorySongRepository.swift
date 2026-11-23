import Foundation

final class MemorySongRepository: SongRepository {
    private var mockSongs: [Song] = [
        Song(id: UUID(), title: "밤의 공기 (Memory)", artist: "윤슬", rating: 4, lyrics: "차가운 도시의 불빛 속에서 널 찾아 헤매..."),
        Song(id: UUID(), title: "Supernova (Memory)", artist: "SIREN", rating: 5, lyrics: "우주 끝까지 터져버릴 것 같은 내 맘을 봐...")
    ]

    func signIn(email: String, password: String) async throws {}

    func signOut() async throws {}

    func fetchSongs() async throws -> [Song] {
        return mockSongs
    }

    func addSong(_ newSong: NewSong) async throws {
        let song = Song(
            id: UUID(),
            title: newSong.title,
            artist: newSong.artist,
            rating: newSong.rating,
            lyrics: newSong.lyrics
        )
        mockSongs.insert(song, at: 0)
    }

    func deleteSong(id: UUID) async throws {
        mockSongs.removeAll { $0.id == id }
    }
}
