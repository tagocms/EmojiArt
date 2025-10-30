//
//  EmojiArtDocumentView.swift
//  EmojiArt
//
//  Created by Tiago Camargo Maciel dos Santos on 24/10/25.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    typealias Emoji = EmojiArt.Emoji
    typealias EmojiPosition = Emoji.Position
    struct Constants {
        static let paletteEmojiSize: CGFloat = 40
    }
    
    @ObservedObject var document: EmojiArtDocument
    @State private var selectedEmojis: Set<Emoji.ID> = []
    
    var body: some View {
        VStack(spacing: 0) {
            documentBody
            PaletteChooser()
                .font(.system(size: Constants.paletteEmojiSize))
                .padding(.horizontal)
                .scrollIndicators(.hidden)
        }
    }
    
    private var documentBody: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white
                documentContents(in: geometry)
                    .scaleEffect(selectedEmojis.isEmpty ? zoom * gestureZoom : zoom)
                    .offset(selectedEmojis.isEmpty ? pan + gesturePan : pan)
            }
            .gesture(allDocumentBodyGestures)
            .dropDestination(for: Sturldata.self) { sturldatas, location in
                drop(sturldatas, at: location, in: geometry)
            }
        }
    }
    
    @State private var zoom: CGFloat = 1
    @State private var pan: CGOffset = .zero
    
    @GestureState private var gestureZoom: CGFloat = 1
    @GestureState private var gesturePan: CGOffset = .zero
    
    private var allDocumentBodyGestures: some Gesture {
        panGesture
            .simultaneously(with: zoomGesture)
            .simultaneously(with: deselectAllEmojisGesture)
    }
    
    private var zoomGesture: some Gesture {
        MagnificationGesture()
            .updating($gestureZoom) { inMotionPinchScale, gestureZoom, _ in
                gestureZoom = inMotionPinchScale
            }
            .onEnded { endingPinchScale in
                if selectedEmojis.isEmpty {
                    zoom *= endingPinchScale
                } else {
                    for emojiID in selectedEmojis {
                        guard let emoji = document.emojis.first(where: { $0.id == emojiID }) else { continue }
                        
                        document.updateEmojiSize(for: emojiID, to: CGFloat(emoji.size) * endingPinchScale)
                    }
                }
            }
    }
    
    private var panGesture: some Gesture {
        DragGesture()
            .updating($gesturePan) { value, gesturePan, _ in
               gesturePan = value.translation
            }
            .onEnded { offset in
                if selectedEmojis.isEmpty {
                    pan += offset.translation
                } else {
                    updateSelectedEmojisPosition(by: offset.translation)
                }
            }
    }
    
    private func selectEmojiGesture(for emoji: Emoji) -> some Gesture {
        TapGesture()
            .onEnded {
                if isEmojiSelected(emoji) {
                    selectedEmojis.remove(emoji.id)
                } else {
                    selectedEmojis.insert(emoji.id)
                }
            }
    }
    
    private var deselectAllEmojisGesture: some Gesture {
        TapGesture()
            .onEnded {
                selectedEmojis.removeAll()
            }
    }
    
    private func updateSelectedEmojisPosition(by offset: CGOffset) {
        for emojiID in selectedEmojis {
            updateEmojiPosition(emojiID, by: offset)
        }
    }
    
    private func updateEmojiPosition(_ emojiID: Emoji.ID, by offset: CGOffset) {
        guard let emoji = document.emojis.first(where: { $0.id == emojiID }) else { return }
        
        let modelOffsetX = offset.width
        let modelOffsetY = -offset.height
        
        document.updateEmojiPosition(
            for: emojiID,
            at: EmojiArt.Emoji.Position(
                x: emoji.position.x + Int(modelOffsetX),
                y: emoji.position.y + Int(modelOffsetY)
            )
        )
    }
    
    private func emojiPosition(at location: CGPoint, in geometry: GeometryProxy) -> Emoji.Position {
        let center = geometry.frame(in: .local).center
        
        return Emoji.Position(
            x: Int((location.x - center.x - pan.width) / zoom),
            y: Int(-(location.y - center.y - pan.height) / zoom)
        )
    }
    
    private func isEmojiSelected(_ emoji: Emoji) -> Bool {
        selectedEmojis.contains(emoji.id)
    }
    
    @ViewBuilder
    private func documentContents(in geometry: GeometryProxy) -> some View {
        AsyncImage(url: document.background) { phase in
            if let image = phase.image {
                image
            } else if let url = document.background {
                if phase.error != nil {
                    Text("\(url)")
                } else {
                    ProgressView()
                }
            }
        }
        .position(Emoji.Position.zero.in(geometry))
        ForEach(document.emojis) { emoji in
            Text(emoji.string)
                .font(emoji.font)
                .border(isEmojiSelected(emoji) ? .gray : .clear, width: 0.5)
                .contextMenu {
                    Button("Delete emoji", role: .destructive) {
                        document.deleteEmoji(emoji)
                    }
                }
                .scaleEffect(isEmojiSelected(emoji) ? 1 * gestureZoom : 1)
                .animation(.default, value: isEmojiSelected(emoji))
                .position(emoji.position.in(geometry))
                .offset(isEmojiSelected(emoji) ? gesturePan : .zero)
                .gesture(selectEmojiGesture(for: emoji))
        }
    }
    
    private func drop(_ sturldatas: [Sturldata], at location: CGPoint, in geometry: GeometryProxy) -> Bool {
        if let sturldata = sturldatas.first {
            switch sturldata {
            case .string(let string):
                document.addEmoji(
                    string,
                    at: emojiPosition(at: location, in: geometry),
                    size: Constants.paletteEmojiSize / zoom
                )
                return true
            case .url(let url):
                document.setBackground(url)
                return true
            case .data(let data):
                break
            }
            return true
        }
        return false
    }
}

#Preview {
    EmojiArtDocumentView(document: EmojiArtDocument())
        .environmentObject(PaletteStore(named: "Preview"))
}
