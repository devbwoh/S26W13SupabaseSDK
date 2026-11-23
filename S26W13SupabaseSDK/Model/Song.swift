import Foundation

struct Song: Identifiable, Decodable, Hashable {
    let id: UUID
    let title: String
    let artist: String
    let rating: Int
    let lyrics: String
}
