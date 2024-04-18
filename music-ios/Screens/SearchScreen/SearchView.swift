import Foundation
import SwiftUI

struct SearchView: View {
    
    @StateObject
    var viewModel: SearchViewModel
    
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
                    if let compositions = viewModel.compositionResults {
                        if compositions.isEmpty {
                            Text("Композиций не найдено")
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
                                viewModel.updateSearchResults()
                            }
                    }
                case .users:
                    if let users = viewModel.userResults {
                        if users.isEmpty {
                            Text("Пользователей не найдено")
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
                                viewModel.updateSearchResults()
                            }
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .refreshable {
            await viewModel.updateSearchResults()
        }
        .scrollIndicators(.hidden)
    }
}
