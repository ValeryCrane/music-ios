import SwiftUI

struct NiceTextField: View {
    
    @Binding private(set) var text: String
    
    private let title: String?
    private let placeholder: String?
    private let isSecure: Bool
    
    @ViewBuilder
    var textField: some View {
        if isSecure {
            SecureField(placeholder ?? "", text: $text)
        } else {
            TextField(placeholder ?? "", text: $text)
        }
    }
    
    var body: some View {
        VStack {
            if let title = title {
                Text(title)
                    .secondaryFont()
            }
            textField
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .primaryFont()
                .multilineTextAlignment(.center)
                .padding(8)
                .frame(maxWidth: .infinity)
                .overlay(
                    RoundedRectangle(cornerRadius: .defaultCornerRadius)
                        .stroke(Color(uiColor: .lightGray.withAlphaComponent(0.3)), lineWidth: 1)
                )
        }
    }
    
    init(_ text: Binding<String>, title: String? = nil, placeholder: String? = nil, isSecure: Bool = false) {
        self._text = text
        self.title = title
        self.placeholder = placeholder
        self.isSecure = isSecure
    }
}

#Preview {
    TestView().padding(.horizontal)
}

fileprivate struct TestView: View {
    
    @State private var text: String = ""
    
    var body: some View {
        NiceTextField($text, title: "Имя пользователя", placeholder: "musicmaker2024")
    }
    
}
