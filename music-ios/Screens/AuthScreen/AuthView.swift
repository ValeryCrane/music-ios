import SwiftUI

struct AuthView: View {
    
    @StateObject
    var viewModel: AuthViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            NiceTextField($viewModel.username, title: "Имя пользователя", placeholder: "musicmaker2004")
            NiceTextField($viewModel.password, title: "Пароль", placeholder: "••••••••", isSecure: true)
                .padding(.bottom, 8)
            NiceButton("Войти", role: .primary) {
                viewModel.onAuthButtonPressed()
            }
            .disabled(viewModel.username.isEmpty || viewModel.password.isEmpty)
            NiceButton("Cоздать аккаунт", role: .secondary) {
                viewModel.onRegisterButtonPressed()
            }
        }
        .padding(.horizontal)
    }
    
    init(viewModel: AuthViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
}

#Preview {
    AuthView(viewModel: AuthViewModel(tokenManager: TokenManager()))
}
