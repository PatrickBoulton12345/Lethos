import SwiftUI

struct HeightEntryView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @FocusState private var feetFocused: Bool
    @FocusState private var inchesFocused: Bool
    @FocusState private var cmFocused: Bool

    @State private var displayCm: String = ""
    @State private var displayFeet: String = ""
    @State private var displayInches: String = ""

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Text("What's your height?")
                .font(LethoFont.headline(28))
                .foregroundColor(.white)

            if viewModel.useImperial {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    TextField("5", text: $displayFeet)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .focused($feetFocused)
                        .frame(maxWidth: 80)
                        .onChange(of: displayFeet) { _, _ in syncImperialToMetric() }

                    Text("ft")
                        .font(LethoFont.headline(24))
                        .foregroundColor(.lethosSecondary)

                    TextField("9", text: $displayInches)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .focused($inchesFocused)
                        .frame(maxWidth: 80)
                        .onChange(of: displayInches) { _, _ in syncImperialToMetric() }

                    Text("in")
                        .font(LethoFont.headline(24))
                        .foregroundColor(.lethosSecondary)
                }
            } else {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    TextField("175", text: $displayCm)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .focused($cmFocused)
                        .frame(maxWidth: 160)
                        .onChange(of: displayCm) { _, newValue in
                            viewModel.heightCm = newValue
                        }

                    Text("cm")
                        .font(LethoFont.headline(24))
                        .foregroundColor(.lethosSecondary)
                }
            }

            unitToggle

            Spacer()
        }
        .padding(.horizontal, LethoSpacing.screenPadding)
        .onAppear {
            if viewModel.useImperial {
                let (ft, inch) = cmToFeetInches(viewModel.heightCm)
                displayFeet = ft
                displayInches = inch
                feetFocused = true
            } else {
                displayCm = viewModel.heightCm
                cmFocused = true
            }
        }
    }

    private var unitToggle: some View {
        Button {
            viewModel.useImperial.toggle()
            if viewModel.useImperial {
                let (ft, inch) = cmToFeetInches(viewModel.heightCm)
                displayFeet = ft
                displayInches = inch
                feetFocused = true
            } else {
                displayCm = viewModel.heightCm
                cmFocused = true
            }
        } label: {
            Text(viewModel.useImperial ? "Switch to metric" : "Switch to imperial")
                .font(LethoFont.body(15))
                .foregroundColor(.lethosSecondary)
                .underline()
        }
        .frame(minHeight: LethoSpacing.minTapTarget)
    }

    private func syncImperialToMetric() {
        let feet = Int(displayFeet) ?? 0
        let inches = Int(displayInches) ?? 0
        let totalInches = feet * 12 + inches
        if totalInches > 0 {
            let cm = Int(round(Double(totalInches) * 2.54))
            viewModel.heightCm = String(cm)
        } else {
            viewModel.heightCm = ""
        }
    }

    private func cmToFeetInches(_ cm: String) -> (String, String) {
        guard let val = Int(cm), val > 0 else { return ("", "") }
        let totalInches = Int(round(Double(val) / 2.54))
        let feet = totalInches / 12
        let inches = totalInches % 12
        return (String(feet), String(inches))
    }
}
