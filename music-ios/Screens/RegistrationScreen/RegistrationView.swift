import SwiftUI

struct RegistrationView: View {
    
    @StateObject
    var viewModel: RegistrationViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            NiceTextField($viewModel.username, title: "Имя пользователя", placeholder: "musicmaker2004")
            NiceTextField($viewModel.email, title: "Электронная почта", placeholder: "mail@music.com")
            NiceTextField($viewModel.password, title: "Пароль", placeholder: "••••••••", isSecure: true)
            NiceTextField($viewModel.repeatedPassword, title: "Повторите пароль", placeholder: "••••••••", isSecure: true)
                .padding(.bottom, 8)
            NiceButton("Cоздать аккаунт", role: .primary) {
                viewModel.onRegisterButtonPressed()
            }
            .disabled(
                viewModel.username.isEmpty || viewModel.email.isEmpty ||
                viewModel.password.isEmpty || viewModel.password != viewModel.repeatedPassword
            )
        }
        .padding(.horizontal)
    }
}

#Preview {
    RegistrationView(viewModel: .init(authManager: .init()))
}
