//
//  ProfileAvatarView.swift
//  music-ios
//
//  Created by valeriy.zhuravlev on 17.04.2024.
//

import SwiftUI

extension ProfileAvatarView {
    private enum Constants {
        static let avatarSize: CGFloat = 128
    }
}

struct ProfileAvatarView: View {
    
    private let avatarURL: URL?
    
    @ViewBuilder
    private var image: some View {
        AsyncImage(url: avatarURL, content: { imagePhase in
            switch imagePhase {
            case .success(let image):
                image.resizable()
                    .aspectRatio(contentMode: .fill)
            case .failure, .empty:
                Color(uiColor: .imp.lightGray)
            @unknown default:
                Color(uiColor: .imp.lightGray)
            }
        })
    }
    
    var body: some View {
        image
            .frame(width: Constants.avatarSize, height: Constants.avatarSize)
            .clipShape(Circle())
            .shadow(color: Color(uiColor: .imp.secondary), radius: 128)
    }
    
    init(avatarURL: URL?) {
        self.avatarURL = avatarURL
    }
}

#Preview {
    ProfileAvatarView(avatarURL: .init(string: "http://localhost/user/avatar?id=19"))
}
