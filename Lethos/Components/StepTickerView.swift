import SwiftUI

struct StepTickerView: View {
    let steps: [OnboardingStep]
    let currentStep: OnboardingStep
    let accentColor: Color

    private var currentIndex: Int {
        steps.firstIndex(of: currentStep) ?? 0
    }

    private var previousTitle: String? {
        guard currentIndex > 0 else { return nil }
        return OnboardingStepConfig.config(for: steps[currentIndex - 1]).tickerTitle
    }

    private var currentConfig: OnboardingStepConfig {
        OnboardingStepConfig.config(for: currentStep)
    }

    private var nextTitle: String? {
        guard currentIndex < steps.count - 1 else { return nil }
        return OnboardingStepConfig.config(for: steps[currentIndex + 1]).tickerTitle
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let prev = previousTitle {
                Text(prev)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.35))
                    .id("prev-\(prev)")
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            HStack(spacing: 8) {
                Image(systemName: currentConfig.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)

                Text(currentConfig.tickerTitle)
                    .font(LethoFont.onboardingTitle(18))
                    .foregroundColor(.white)
            }
            .id("current-\(currentStep)")
            .transition(.move(edge: .bottom).combined(with: .opacity))

            if let next = nextTitle {
                Text(next)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(accentColor.opacity(0.5))
                    .id("next-\(next)")
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: currentStep)
    }
}
