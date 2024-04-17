import Foundation
import SwiftUI

struct CompositionsView: View {
    
    @StateObject
    var viewModel: CompositionsViewModel
    
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        if let compositions = viewModel.compositions {
            ScrollView {
                if compositions.isEmpty {
                    Text("Композиций не найдено")
                        .secondaryFont()
                        .padding(16)
                    Spacer()
                } else {
                    LazyVGrid(columns: columns, spacing: 16, content: {
                        ForEach(compositions, id: \.id) { composition in
                            CompositionMiniatureView(
                                title: composition.name,
                                playState: .paused,
                                onPlayButtonTap: { },
                                isFavourite: .constant(composition.isFavourite)
                            )
                        }
                    })
                    .padding(16)
                }
            }
            .refreshable {
                await viewModel.updateCompositions()
            }
        } else {
            ProgressView()
                .onAppear {
                    viewModel.loadCompositions()
                }
        }
    }
}

#Preview {
    CompositionsView(viewModel: .init(compositionManager: .init()))
}
