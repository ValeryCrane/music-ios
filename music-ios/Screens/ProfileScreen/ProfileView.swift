import Foundation
import SwiftUI

struct ProfileView: View {
    
    @StateObject
    var viewModel: ProfileViewModel
    
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        if
            let avatarURL = viewModel.avatarURL,
            let username = viewModel.username,
            let compositionCount = viewModel.compositionCount
        {
            ScrollView {
                VStack {
                    AvatarView(avatarURL: avatarURL, size: 128)
                        .id(viewModel.avatarId)
                        .padding(.top, 32)
                        .padding(.bottom, 8)
                    
                    Text(username).titleFont()
                    if let email = viewModel.email {
                        Text(email).secondaryFont()
                    }
                    Text("\(compositionCount) композиций")
                        .secondaryFont()
                        .padding(.bottom, 24)
                    Text("Композиции")
                        .titleFont()
                        .padding(.bottom, 16)
                    
                    if let compositions = viewModel.compositions {
                        LazyVGrid(columns: columns, spacing: 16, content: {
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
                        })
                        .padding(.horizontal, 16)
                    } else {
                        ProgressView()
                            .onAppear {
                                viewModel.loadCompositions()
                            }
                    }
                    Spacer()
                }
            }
            .scrollIndicators(.hidden)
            .confirmationDialog("", isPresented: $viewModel.isLogoutConfirmationPresented) {
                Button("Выйти", role: .destructive) {
                    viewModel.onLogoutConfirmed()
                }
            }
        } else {
            ProgressView()
                .onAppear {
                    viewModel.loadUser()
                }
        }
    }
}

#Preview {
    ProfileView(viewModel: .init(userManager: .init()))
}
