import Foundation
import Supabase

final class SupabaseSongRepository: SongRepository {
    private let client = SupabaseManager.client

    func signIn(email: String, password: String) async throws {
        _ = try await client.auth.signIn(email: email, password: password)
    }

    func signOut() async throws {
        try await client.auth.signOut()
    }

    func fetchSongs() async throws -> [Song] {
        return try await client
            .from("songs")
            .select()
            .order("created_at", ascending: false)
            .execute()
            .value
    }

    func addSong(_ newSong: NewSong) async throws {
        try await client
            .from("songs")
            .insert(newSong)
            .execute()
    }

    func deleteSong(id: UUID) async throws {
        try await client
            .from("songs")
            .delete()
            .eq("id", value: id)
            .execute()
    }
}
