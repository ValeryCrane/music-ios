import SwiftUI

struct EditProfileView: View {
    
    @StateObject
    var viewModel: EditProfileViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            Button(action: {
                viewModel.onEditProfilePictureButtonPressed()
            }) {
                if let image = viewModel.avatarImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 72, height: 72)
                        .clipShape(Circle())
                } else {
                    ZStack {
                        Color(uiColor: .imp.lightGray)
                            .frame(width: 72, height: 72)
                            .clipShape(Circle())
                        Image(systemName: "photo.badge.plus")
                    }
                }
            }
            .padding(.vertical, 24)
            
            NiceTextField(
                $viewModel.username,
                title: "Новое имя пользователя",
                placeholder: "new_username"
            )
            
            NiceTextField(
                $viewModel.email,
                title: "Новая электронная почта",
                placeholder: "new_email@mail.com"
            )
            
            NiceTextField(
                $viewModel.password,
                title: "Новый пароль",
                placeholder: "••••••••",
                isSecure: true
            )
            
            NiceTextField(
                $viewModel.repeatedPassword,
                title: "Повторите новый пароль",
                placeholder: "••••••••",
                isSecure: true
            )
            
            NiceButton("Сохранить", role: .primary) {
                viewModel.onSaveButtonPressed()
            }
            .padding(.top, 16)
            NiceButton("Удалить аккаунт", role: .secondary) {
                viewModel.onDeleteAccountButtonPressed()
            }
            Spacer()
        }
        .padding(.horizontal)
        .confirmationDialog("", isPresented: $viewModel.isDeleteAccountConfirmationPresented) {
            Button("Удалить аккаунт", role: .destructive) {
                viewModel.onDeleteAccountConfirmed()
            }
        }
    }
}

#Preview {
    EditProfileView(viewModel: .init(userManager: .init()))
}
