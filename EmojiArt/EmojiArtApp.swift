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
    @StateObject var paletteStore = PaletteStore(named: "Main")
    @StateObject var paletteStore2 = PaletteStore(named: "2")
    @StateObject var paletteStore3 = PaletteStore(named: "3")
    
    
    var body: some Scene {
        WindowGroup {
//            PaletteManager(stores: [paletteStore, paletteStore2, paletteStore3])
            EmojiArtDocumentView(document: defaultDocument)
                .environmentObject(paletteStore)
        }
    }
}
