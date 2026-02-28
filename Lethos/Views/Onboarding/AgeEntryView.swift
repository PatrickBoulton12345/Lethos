import SwiftUI

struct AgeEntryView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Text("What's your age?")
                .font(LethoFont.headline(28))
                .foregroundColor(.lethosPrimary)

            TextField("25", text: $viewModel.age)
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.lethosPrimary)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .focused($isFocused)
                .frame(maxWidth: 120)

            Spacer()
        }
        .padding(.horizontal, LethoSpacing.screenPadding)
        .onAppear { isFocused = true }
    }
}
