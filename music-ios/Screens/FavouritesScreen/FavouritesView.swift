import Foundation
import SwiftUI

extension FavouritesView {
    enum FavouritesGroup: String, CaseIterable, Identifiable {
        var id: Self { return self }
        
        case compositions = "Композиции"
        case users = "Пользователи"
    }
}

struct FavouritesView: View {
    
    @StateObject
    var viewModel: FavouritesViewModel
    
    @State
    private var favouritesGroup: FavouritesGroup = .compositions
    
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ScrollView {
            VStack {
                Picker(
                    "Выберите группу",
                    selection: $favouritesGroup
                ) {
                    ForEach(FavouritesGroup.allCases, id: \.id) { group in
                        Text(group.rawValue).tag(group)
                            .primaryFont()
                    }
                }
                .pickerStyle(PalettePickerStyle())
                
                switch favouritesGroup {
                case .compositions:
                    if let compositions = viewModel.favouriteCompositions {
                        if compositions.isEmpty {
                            Text("Избранные композиции отсутствуют")
                                .secondaryFont()
                                .padding(32)
                        } else {
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(compositions, id: \.id) { composition in
                                    CompositionMiniatureView(
                                        title: composition.name,
                                        playState: .paused,
                                        onPlayButtonTap: { },
                                        isFavourite: .constant(composition.isFavourite)
                                    )
                                }
                            }
                        }
                    } else {
                        ProgressView()
                            .padding(32)
                            .onAppear {
                                viewModel.loadCompositions()
                            }
                    }
                case .users:
                    if let users = viewModel.favouriteUsers {
                        if users.isEmpty {
                            Text("Избранные пользователи отсутствуют")
                                .secondaryFont()
                                .padding(32)
                        } else {
                            VStack {
                                ForEach(users, id: \.id) { user in
                                    HStack {
                                        AvatarView(avatarURL: user.avatarURL, size: 48)
                                            .padding(.trailing, 16)
                                        Text(user.username)
                                            .primaryFont()
                                        Spacer()
                                        Text("\(user.compositionCount)")
                                            .secondaryFont()
                                        Image(systemName: "chevron.right")
                                            .foregroundStyle(.gray)
                                    }
                                    .padding(16)
                                    .background(Color(uiColor: .imp.lightGray))
                                    .clipShape(RoundedRectangle(cornerRadius: .defaultCornerRadius))
                                    .padding(.vertical, 4)
                                }
                            }
                            .padding(.vertical, 16)
                        }
                    } else {
                        ProgressView()
                            .padding(32)
                            .onAppear {
                                viewModel.loadUsers()
                            }
                    }
                }
            }
            .padding(16)
        }
        .refreshable {
            switch favouritesGroup {
            case .compositions:
                await viewModel.updateCompositions()
            case .users:
                await viewModel.updateUsers()
            }
        }
    }
}

#Preview {
    FavouritesView(viewModel: .init(favouritesManager: .init()))
}
