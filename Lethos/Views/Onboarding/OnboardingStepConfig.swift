import SwiftUI

struct OnboardingStepConfig {
    let tickerTitle: String
    let icon: String
    let accentColor: Color
    let buttonTitle: String?
    let showBackButton: Bool

    static func config(for step: OnboardingStep) -> OnboardingStepConfig {
        switch step {
        case .welcome:
            return OnboardingStepConfig(
                tickerTitle: "Welcome",
                icon: "hand.wave.fill",
                accentColor: .onboardingTeal,
                buttonTitle: "GET STARTED",
                showBackButton: false
            )
        case .tellUsAboutYou:
            return OnboardingStepConfig(
                tickerTitle: "About You",
                icon: "person.fill",
                accentColor: .onboardingBlue,
                buttonTitle: nil,
                showBackButton: true
            )
        case .photoAnalysing:
            return OnboardingStepConfig(
                tickerTitle: "Analysing",
                icon: "sparkles",
                accentColor: .onboardingCyan,
                buttonTitle: nil,
                showBackButton: false
            )
        case .photoResult:
            return OnboardingStepConfig(
                tickerTitle: "Your Build",
                icon: "checkmark.circle.fill",
                accentColor: .onboardingSkyBlue,
                buttonTitle: nil,
                showBackButton: true
            )
        case .manualWeight:
            return OnboardingStepConfig(
                tickerTitle: "Your Weight",
                icon: "scalemass.fill",
                accentColor: .onboardingPurple,
                buttonTitle: "CONTINUE",
                showBackButton: true
            )
        case .manualHeight:
            return OnboardingStepConfig(
                tickerTitle: "Your Height",
                icon: "ruler.fill",
                accentColor: .onboardingViolet,
                buttonTitle: "CONTINUE",
                showBackButton: true
            )
        case .buildSelection:
            return OnboardingStepConfig(
                tickerTitle: "Your Build",
                icon: "figure.stand",
                accentColor: .onboardingAmber,
                buttonTitle: "CONTINUE",
                showBackButton: true
            )
        case .manualAge:
            return OnboardingStepConfig(
                tickerTitle: "Your Age",
                icon: "calendar",
                accentColor: .onboardingIndigo,
                buttonTitle: "CONTINUE",
                showBackButton: true
            )
        case .manualGender:
            return OnboardingStepConfig(
                tickerTitle: "Gender",
                icon: "person.2.fill",
                accentColor: .onboardingRose,
                buttonTitle: "CONTINUE",
                showBackButton: true
            )
        case .dietaryRequirements:
            return OnboardingStepConfig(
                tickerTitle: "Diet",
                icon: "fork.knife",
                accentColor: .onboardingOrange,
                buttonTitle: "CONTINUE",
                showBackButton: true
            )
        case .goalPhysique:
            return OnboardingStepConfig(
                tickerTitle: "Your Goal",
                icon: "target",
                accentColor: .onboardingGold,
                buttonTitle: "CONTINUE",
                showBackButton: true
            )
        case .goalAnalysing:
            return OnboardingStepConfig(
                tickerTitle: "Analysing",
                icon: "sparkles",
                accentColor: .onboardingLime,
                buttonTitle: nil,
                showBackButton: false
            )
        case .paywall:
            return OnboardingStepConfig(
                tickerTitle: "Get Started",
                icon: "star.fill",
                accentColor: .lethosGreen,
                buttonTitle: nil,
                showBackButton: false
            )
        }
    }

    /// Computes the ordered step path based on the user's chosen onboarding route.
    @MainActor static func resolvedStepPath(for viewModel: OnboardingViewModel) -> [OnboardingStep] {
        var steps: [OnboardingStep] = [.welcome, .tellUsAboutYou]

        if viewModel.usedPhotoPath {
            steps.append(.photoAnalysing)
            if viewModel.aiConfidenceHigh {
                steps.append(.photoResult)
            } else {
                steps.append(.buildSelection)
            }
            steps.append(contentsOf: [.manualAge, .manualGender])
        } else {
            steps.append(contentsOf: [.manualGender, .manualWeight, .manualHeight, .buildSelection])
        }

        steps.append(contentsOf: [.dietaryRequirements, .goalPhysique, .paywall])
        return steps
    }
}
