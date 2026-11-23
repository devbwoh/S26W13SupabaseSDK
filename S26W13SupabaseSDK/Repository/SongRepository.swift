import Foundation

protocol SongRepository: Sendable {
    func signIn(email: String, password: String) async throws
    func signOut() async throws
    func fetchSongs() async throws -> [Song]
    func addSong(_ newSong: NewSong) async throws
    func deleteSong(id: UUID) async throws
}
