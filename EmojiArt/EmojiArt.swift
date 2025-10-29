//
//  EmojiArt.swift
//  EmojiArt
//
//  Created by Tiago Camargo Maciel dos Santos on 24/10/25.
//

import Foundation

struct EmojiArt {
    var background: URL?
    private(set) var emojis = [Emoji]()
    
    private var uniqueEmojiId = 0
    
    mutating func addEmoji(_ emoji: String, at position: Emoji.Position, size: Int) {
        uniqueEmojiId += 1
        emojis.append(Emoji(string: emoji, position: position, size: size, id: uniqueEmojiId))
    }
    
    mutating func updateEmojiPosition(_ emojiID: Emoji.ID, at position: Emoji.Position) {
        guard let emojiIndex = emojis.firstIndex(where: { $0.id == emojiID } ) else { return }
        
        emojis[emojiIndex].position = position
    }
    
    mutating func updateEmojiSize(_ emojiID: Emoji.ID, to size: Int) {
        guard let emojiIndex = emojis.firstIndex(where: { $0.id == emojiID } ) else { return }
        
        emojis[emojiIndex].size = size
    }
    
    mutating func deleteEmoji(_ emojiID: Emoji.ID) {
        emojis.removeAll { $0.id == emojiID }
    }
    
    struct Emoji: Identifiable, Equatable {
        let string: String
        var position: Position
        var size: Int
        var id: Int
        
        struct Position {
            var x: Int
            var y: Int
            
            static let zero = Self(x: 0, y: 0)
        }
        
        static func ==(lhs: Emoji, rhs: Emoji) -> Bool {
            lhs.id == rhs.id
        }
    }
}
