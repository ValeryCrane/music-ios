import Foundation
import SwiftUI

struct FavouritesView: View {
    
    @StateObject
    var viewModel: FavouritesViewModel
    
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ScrollView {
            VStack {
                Picker(
                    "Выберите группу",
                    selection: $viewModel.currentGroup
                ) {
                    ForEach(SearchGroup.allCases, id: \.id) { group in
                        Text(group.rawValue).tag(group)
                            .primaryFont()
                    }
                }
                .pickerStyle(PalettePickerStyle())
                
                switch viewModel.currentGroup {
                case .compositions:
                    if let compositions = viewModel.favouriteCompositions {
                        if compositions.isEmpty {
                            Text("Избранные композиции отсутствуют")
                                .secondaryFont()
                                .padding(32)
                        } else {
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(Array(compositions.enumerated()), id: \.offset) { index, composition in
                                    CompositionMiniatureView(
                                        miniature: composition,
                                        playState: viewModel.compositionStates[index],
                                        onPlayButtonTap: {
                                            viewModel.compositionPlayButtonTapped(atIndex: index)
                                        },
                                        onFavouriteButtonTap: {
                                            viewModel.compositionFavouriteButtonTapped(atIndex: index)
                                        }
                                    )
                                    .onTapGesture {
                                        viewModel.compositionTapped(atIndex: index)
                                    }
                                }
                            }
                        }
                    } else {
                        ProgressView()
                            .padding(32)
                            .onAppear {
                                viewModel.loadCurrentGroup()
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
                                viewModel.loadCurrentGroup()
                            }
                    }
                }
            }
            .padding(16)
        }
        .refreshable {
            await viewModel.updateCurrentGroup()
        }
    }
}

#Preview {
    FavouritesView(viewModel: .init(favouritesManager: .init()))
}
