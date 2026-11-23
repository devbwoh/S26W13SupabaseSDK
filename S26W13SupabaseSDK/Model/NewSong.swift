import Foundation

struct NewSong: Encodable {
    let title: String
    let artist: String
    let rating: Int
    let lyrics: String
}
