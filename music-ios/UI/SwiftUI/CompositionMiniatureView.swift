import SwiftUI

extension CompositionMiniatureView {
    enum PlayState {
        case paused
        case playing
        case loading
    }
}

struct CompositionMiniatureView: View {

    private let miniature: CompositionMiniature
    private let playState: PlayState
    private let onPlayButtonTap: () -> Void
    private let onFavouriteButtonTap: () -> Void

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
        Image(systemName: miniature.isFavourite ? "heart.fill": "heart")
            .resizable()
            .fontWeight(.bold)
            .foregroundStyle(Color(uiColor: .imp.primary))
    }
    
    var body: some View {
        ZStack {
            Color(uiColor: .imp.lightGray)
            VStack {
                HStack {
                    Text(miniature.name)
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
                        onFavouriteButtonTap()
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
        miniature: CompositionMiniature,
        playState: PlayState,
        onPlayButtonTap: @escaping () -> Void,
        onFavouriteButtonTap: @escaping () -> Void
    ) {
        self.miniature = miniature
        self.playState = playState
        self.onPlayButtonTap = onPlayButtonTap
        self.onFavouriteButtonTap = onFavouriteButtonTap
    }
}

#Preview {
    CompositionMiniatureView(
        miniature: .init(id: 1, name: "Композиция", isFavourite: true),
        playState: .playing,
        onPlayButtonTap: {},
        onFavouriteButtonTap: {}
    )
    .frame(maxWidth: 170)
}
