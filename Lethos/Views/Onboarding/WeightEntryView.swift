import SwiftUI

struct WeightEntryView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @FocusState private var isFocused: Bool
    @State private var displayValue: String = ""

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Text("What's your weight?")
                .font(LethoFont.headline(28))
                .foregroundColor(.lethosPrimary)

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                TextField(viewModel.useImperial ? "165" : "75", text: $displayValue)
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.lethosPrimary)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
                    .focused($isFocused)
                    .frame(maxWidth: 160)
                    .onChange(of: displayValue) { _, newValue in
                        syncToMetric(newValue)
                    }

                Text(viewModel.useImperial ? "lbs" : "kg")
                    .font(LethoFont.headline(24))
                    .foregroundColor(.lethosSecondary)
            }

            unitToggle

            Spacer()
        }
        .padding(.horizontal, LethoSpacing.screenPadding)
        .onAppear {
            displayValue = viewModel.useImperial ? kgToLbs(viewModel.weightKg) : viewModel.weightKg
            isFocused = true
        }
    }

    private var unitToggle: some View {
        Button {
            let wasImperial = viewModel.useImperial
            viewModel.useImperial.toggle()
            if viewModel.useImperial {
                displayValue = kgToLbs(viewModel.weightKg)
            } else {
                displayValue = viewModel.weightKg
            }
        } label: {
            Text(viewModel.useImperial ? "Switch to metric" : "Switch to imperial")
                .font(LethoFont.body(15))
                .foregroundColor(.lethosSecondary)
                .underline()
        }
        .frame(minHeight: LethoSpacing.minTapTarget)
    }

    private func syncToMetric(_ value: String) {
        if viewModel.useImperial {
            if let lbs = Double(value) {
                let kg = lbs / 2.20462
                viewModel.weightKg = String(format: "%.1f", kg)
            } else {
                viewModel.weightKg = ""
            }
        } else {
            viewModel.weightKg = value
        }
    }

    private func kgToLbs(_ kg: String) -> String {
        guard let val = Double(kg), val > 0 else { return "" }
        return String(format: "%.0f", val * 2.20462)
    }
}
