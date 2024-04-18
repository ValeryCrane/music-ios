import SwiftUI

struct AvatarView: View {
    
    private let avatarURL: URL?
    private let size: CGFloat
    
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
            .frame(width: size, height: size)
            .clipShape(Circle())
    }
    
    init(avatarURL: URL?, size: CGFloat) {
        self.avatarURL = avatarURL
        self.size = size
    }
}

#Preview {
    AvatarView(avatarURL: .init(string: "http://localhost/user/avatar?id=19"), size: 128)
}
