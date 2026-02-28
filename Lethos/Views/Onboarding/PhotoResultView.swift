import SwiftUI

struct PhotoResultView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: LethoSpacing.sectionSpacing) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.lethosGreenDark)
                    .frame(width: 80, height: 80)
                Image(systemName: "checkmark")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.lethosGreenAccent)
            }

            VStack(spacing: 12) {
                Text("We think you're:")
                    .font(LethoFont.body())
                    .foregroundColor(.lethosSecondary)

                Text(viewModel.selectedBodyType?.displayName ?? "Unknown")
                    .font(LethoFont.headline(28))
                    .foregroundColor(.lethosGreenAccent)

                if let notes = viewModel.bodyAnalysis?.notes {
                    Text(notes)
                        .font(LethoFont.body(15))
                        .foregroundColor(.lethosSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                }
            }

            Spacer()

            VStack(spacing: 12) {
                OnboardingContinueButton(title: "THAT'S RIGHT") {
                    viewModel.acceptPhotoResult()
                }

                Button {
                    viewModel.rejectPhotoResult()
                } label: {
                    Text("Not quite — let me choose")
                        .font(LethoFont.body())
                        .foregroundColor(.lethosSecondary)
                        .underline()
                }
                .frame(minHeight: LethoSpacing.minTapTarget)
            }
            .padding(.horizontal, LethoSpacing.screenPadding)
            .padding(.bottom, 40)
        }
        .padding(.horizontal, LethoSpacing.screenPadding)
    }
}
