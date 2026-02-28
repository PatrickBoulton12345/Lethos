import SwiftUI

struct DietaryRequirementsView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text("Dietary requirements")
                .font(LethoFont.headline(28))
                .foregroundColor(.white)
                .padding(.top, 8)

            Text("Select all that apply")
                .font(LethoFont.body(15))
                .foregroundColor(.lethosSecondary)

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(DietaryRequirement.allCases) { req in
                        Button {
                            toggleDietary(req)
                        } label: {
                            GlowCard(isSelected: viewModel.selectedDietary.contains(req)) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(req.displayName)
                                        .font(LethoFont.headline(18))
                                        .foregroundColor(.white)

                                    if req == .other && viewModel.selectedDietary.contains(.other) {
                                        TextField("Tell us more...", text: $viewModel.otherDietaryText)
                                            .font(LethoFont.body(15))
                                            .foregroundColor(.white)
                                            .padding(12)
                                            .background(Color.lethosBlack)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                                }
                            }
                        }
                        .buttonStyle(GlowButtonStyle())
                    }
                }
                .padding(.horizontal, LethoSpacing.screenPadding)
            }
        }
    }

    private func toggleDietary(_ req: DietaryRequirement) {
        if req == .noRestrictions {
            viewModel.selectedDietary = [.noRestrictions]
        } else {
            viewModel.selectedDietary.remove(.noRestrictions)
            if viewModel.selectedDietary.contains(req) {
                viewModel.selectedDietary.remove(req)
            } else {
                viewModel.selectedDietary.insert(req)
            }
        }
    }
}
