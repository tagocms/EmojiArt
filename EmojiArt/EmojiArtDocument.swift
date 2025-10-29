//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by Tiago Camargo Maciel dos Santos on 24/10/25.
//

import SwiftUI

class EmojiArtDocument: ObservableObject {
    typealias Emoji = EmojiArt.Emoji
    typealias EmojiPosition = EmojiArt.Emoji.Position
    
    @Published private var emojiArt = EmojiArt()
    var emojis: [Emoji] { emojiArt.emojis }
    var background: URL? { emojiArt.background }
    
    init() {
        self.emojiArt.addEmoji("🚲", at: .init(x: -200, y: -150), size: 200)
        self.emojiArt.addEmoji("🔥", at: .init(x: 200, y: 100), size: 80)
    }
    
    // MARK: - Intents
    func setBackground(_ url: URL?) {
        emojiArt.background = url
    }
    
    func addEmoji(_ emoji: String, at position: Emoji.Position, size: CGFloat) {
        emojiArt.addEmoji(emoji, at: position, size: Int(size))
    }
    
    func deleteEmoji(_ emoji: Emoji) {
        emojiArt.deleteEmoji(emoji.id)
    }
    
    func updateEmojiPosition(for emojiID: Emoji.ID, at position: EmojiPosition) {
        emojiArt.updateEmojiPosition(emojiID, at: position)
    }
    
    func updateEmojiSize(for emojiID: Emoji.ID, to size: CGFloat) {
        emojiArt.updateEmojiSize(emojiID, to: Int(size))
    }
}

extension EmojiArt.Emoji {
    var font: Font {
        Font.system(size: CGFloat(size))
    }
}

extension EmojiArt.Emoji.Position {
    func `in`(_ geometry: GeometryProxy) -> CGPoint {
        let center = geometry.frame(in: .local).center
        return CGPoint(x: center.x + CGFloat(x), y: center.y - CGFloat(y))
    }
}
