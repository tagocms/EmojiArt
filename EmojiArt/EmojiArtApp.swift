//
//  EmojiArtApp.swift
//  EmojiArt
//
//  Created by Tiago Camargo Maciel dos Santos on 24/10/25.
//

import SwiftUI

@main
struct EmojiArtApp: App {
    @StateObject var defaultDocument = EmojiArtDocument()
    
    var body: some Scene {
        WindowGroup {
            EmojiArtDocumentView(document: defaultDocument)
        }
    }
}
