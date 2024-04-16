import SwiftUI

extension CompositionMiniatureView {
    enum PlayState {
        case paused
        case playing
        case loading
    }
}

struct CompositionMiniatureView: View {
    
    private let title: String
    private let playState: PlayState
    private let onPlayButtonTap: () -> Void
    
    @Binding
    private var isFavourite: Bool?
    
    @ViewBuilder
    var playButtonContent: some View {
        switch playState {
        case .paused:
            Image(systemName: "play.fill")
                .resizable()
                .foregroundStyle(Color(uiColor: .imp.primary))
        case .playing:
            Image(systemName: "pause.fill")
                .resizable()
                .foregroundStyle(Color(uiColor: .imp.primary))
        case .loading:
            ProgressView()
        }
    }
    
    @ViewBuilder
    var favouriteButtonContent: some View {
        if let isFavourite = isFavourite {
            Image(systemName: isFavourite ? "heart.fill": "heart")
                .resizable()
                .fontWeight(.bold)
                .foregroundStyle(Color(uiColor: .imp.primary))
        }
    }
    
    var body: some View {
        ZStack {
            Color(uiColor: .imp.lightGray)
            VStack {
                HStack {
                    Text(title)
                        .titleFont()
                        .lineLimit(2)
                        .padding(16)
                    Spacer()
                }
                Spacer()
            }
            
            VStack {
                Spacer()
                HStack {
                    Button(action: {
                        isFavourite?.toggle()
                    }, label: {
                        favouriteButtonContent
                    })
                    .frame(width: 24, height: 24)
                    .padding(16)
                    Spacer()
                }
            }
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        if playState != .loading {
                            onPlayButtonTap()
                        }
                    }, label: {
                        playButtonContent
                    })
                    .frame(width: 24, height: 24)
                    .padding(16)
                }
            }

        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .aspectRatio(1.0, contentMode: .fit)
    }
    
    init(
        title: String,
        playState: PlayState,
        onPlayButtonTap: @escaping () -> Void,
        isFavourite: Binding<Bool?> = .constant(nil)
    ) {
        self.title = title
        self.playState = playState
        self.onPlayButtonTap = onPlayButtonTap
        self._isFavourite = isFavourite
    }
}

#Preview {
    CompositionMiniatureView(
        title: "My favourite track",
        playState: .paused,
        onPlayButtonTap: {},
        isFavourite: .constant(false)
    )
    .frame(maxWidth: 170)
}
