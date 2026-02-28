import SwiftUI

struct BuildSelectionView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text("What's your build?")
                .font(LethoFont.headline(28))
                .foregroundColor(.white)
                .padding(.top, 8)

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(BodyType.allCases) { type in
                        ExpandableBuildCard(
                            bodyType: type,
                            isSelected: viewModel.selectedBodyType == type,
                            allowExpand: viewModel.allowBuildExpand
                        ) {
                            viewModel.selectedBodyType = type
                        }
                    }
                }
                .padding(.horizontal, LethoSpacing.screenPadding)
            }
        }
    }
}
