import SwiftUI

struct GenderSelectionView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: LethoSpacing.sectionSpacing) {
            Spacer()

            Text("What's your gender?")
                .font(LethoFont.headline(28))
                .foregroundColor(.white)

            VStack(spacing: 12) {
                ForEach(Gender.allCases) { gender in
                    Button {
                        viewModel.selectedGender = gender
                    } label: {
                        GlowCard(isSelected: viewModel.selectedGender == gender) {
                            Text(gender.displayName)
                                .font(LethoFont.headline(18))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(GlowButtonStyle())
                }
            }
            .padding(.horizontal, LethoSpacing.screenPadding)

            Spacer()
        }
        .padding(.horizontal, LethoSpacing.screenPadding)
    }
}
