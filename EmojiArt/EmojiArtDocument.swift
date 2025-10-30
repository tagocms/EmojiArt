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
    
    @Published private var emojiArt = EmojiArt() {
        didSet {
            autosave()
        }
    }
    var emojis: [Emoji] { emojiArt.emojis }
    var background: URL? { emojiArt.background }
    
    init() {
        if let data = try? Data(contentsOf: autosaveURL) {
            if let autosavedEmojiArt = try? EmojiArt(json: data) {
                emojiArt = autosavedEmojiArt
            }
        }
    }
    
    private let autosaveURL: URL = URL.documentsDirectory.appendingPathComponent("Autosaved.emojiart")
    
    private func autosave() {
        save(to: autosaveURL)
        print("Autosaved to \(autosaveURL)")
    }
    private func save(to url: URL) {
        do {
            let data = try emojiArt.json()
            try data.write(to: url)
        } catch let error {
            print("EmojiArtDocument: error while saving \(error.localizedDescription)")
        }
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
