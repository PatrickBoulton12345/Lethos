import SwiftUI

struct OnboardingContainerView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    let onComplete: (UserProfile, Data?, Bool) -> Void

    private var config: OnboardingStepConfig {
        OnboardingStepConfig.config(for: viewModel.currentStep)
    }

    private var resolvedPath: [OnboardingStep] {
        OnboardingStepConfig.resolvedStepPath(for: viewModel)
    }

    private var currentIndex: Int {
        resolvedPath.firstIndex(of: viewModel.currentStep) ?? 0
    }

    private var showTicker: Bool {
        let s = viewModel.currentStep
        return s != .photoAnalysing && s != .goalAnalysing && s != .paywall
    }

    private var showDots: Bool {
        let s = viewModel.currentStep
        return s != .photoAnalysing && s != .goalAnalysing && s != .paywall
    }

    private var canContinue: Bool {
        switch viewModel.currentStep {
        case .welcome: return true
        case .manualWeight: return !viewModel.weightKg.isEmpty
        case .manualHeight: return !viewModel.heightCm.isEmpty
        case .buildSelection: return viewModel.selectedBodyType != nil
        case .manualAge: return !viewModel.age.isEmpty
        case .manualGender: return viewModel.selectedGender != nil
        case .dietaryRequirements: return !viewModel.selectedDietary.isEmpty
        case .goalPhysique: return viewModel.goalImageData != nil
        default: return false
        }
    }

    private var forwardTransition: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }

    private var backwardTransition: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .leading).combined(with: .opacity),
            removal: .move(edge: .trailing).combined(with: .opacity)
        )
    }

    var body: some View {
        ZStack {
            // Ambient gradient background
            LinearGradient(
                colors: [.black, config.accentColor.opacity(0.6)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.5), value: viewModel.currentStep)

            // Fixed chrome + sliding content
            VStack(spacing: 0) {
                // Back button — stays in place
                HStack {
                    if config.showBackButton {
                        Button {
                            viewModel.goBack()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white.opacity(0.7))
                                .frame(width: 44, height: 44)
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 8)
                .frame(height: 44)

                // Step ticker — stays in place, animates its own text
                if showTicker {
                    HStack {
                        StepTickerView(
                            steps: resolvedPath,
                            currentStep: viewModel.currentStep,
                            accentColor: config.accentColor
                        )
                        Spacer()
                    }
                    .padding(.horizontal, LethoSpacing.screenPadding)
                    .padding(.bottom, 16)
                }

                // Content area — THIS slides
                ZStack {
                    contentView(for: viewModel.currentStep)
                        .id(viewModel.currentStep)
                        .transition(viewModel.navigatingForward ? forwardTransition : backwardTransition)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
                .animation(.easeInOut(duration: 0.35), value: viewModel.currentStep)

                // Page dots — stays in place
                if showDots {
                    PageDotsView(
                        totalSteps: resolvedPath.count,
                        currentIndex: currentIndex
                    )
                    .padding(.bottom, 16)
                    .animation(.easeInOut(duration: 0.3), value: currentIndex)
                }

                // Continue button — stays in place
                if let buttonTitle = config.buttonTitle {
                    OnboardingContinueButton(
                        title: buttonTitle,
                        isEnabled: canContinue,
                        action: { onContinue() }
                    )
                    .padding(.horizontal, LethoSpacing.screenPadding)
                    .padding(.bottom, 40)
                }
            }
        }
    }

    // MARK: - Continue action

    private func onContinue() {
        switch viewModel.currentStep {
        case .welcome: viewModel.navigateTo(.tellUsAboutYou)
        case .manualWeight: viewModel.submitWeight()
        case .manualHeight: viewModel.submitHeight()
        case .buildSelection: viewModel.submitBuild()
        case .manualAge: viewModel.submitAge()
        case .manualGender: viewModel.submitGender()
        case .dietaryRequirements: viewModel.submitDietary()
        case .goalPhysique: viewModel.submitGoalPhoto()
        default: break
        }
    }

    // MARK: - Content only (no chrome)

    @ViewBuilder
    private func contentView(for step: OnboardingStep) -> some View {
        switch step {
        case .welcome:
            VStack(spacing: 16) {
                Spacer()

                Text("LETHOS")
                    .font(.custom("ClashDisplay-Semibold", size: 52))
                    .foregroundStyle(LinearGradient.lethosGreen)

                Text("Your AI-powered physique coach")
                    .font(LethoFont.body())
                    .foregroundColor(.lethosSecondary)

                Text("Get your personalised workout plan in SECONDS")
                    .font(LethoFont.body(15))
                    .foregroundColor(.lethosFinePrint)
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)

                Spacer()
            }
            .padding(.horizontal, LethoSpacing.screenPadding)

        case .tellUsAboutYou:
            TellUsAboutYouView(viewModel: viewModel)

        case .photoAnalysing:
            LoadingView(
                title: "Analysing...",
                subtitle: "Our AI is assessing your current physique",
                accentColor: OnboardingStepConfig.config(for: .photoAnalysing).accentColor
            )

        case .photoResult:
            PhotoResultView(viewModel: viewModel)

        case .manualWeight:
            WeightEntryView(viewModel: viewModel)

        case .manualHeight:
            HeightEntryView(viewModel: viewModel)

        case .buildSelection:
            BuildSelectionView(viewModel: viewModel)

        case .manualAge:
            AgeEntryView(viewModel: viewModel)

        case .manualGender:
            GenderSelectionView(viewModel: viewModel)

        case .dietaryRequirements:
            DietaryRequirementsView(viewModel: viewModel)

        case .goalPhysique:
            GoalPhysiqueView(viewModel: viewModel)

        case .goalAnalysing:
            LoadingView(
                title: "Almost there...",
                subtitle: "Your goal is saved — unlock your plan to see your AI analysis",
                accentColor: OnboardingStepConfig.config(for: .goalAnalysing).accentColor
            )

        case .paywall:
            PaywallView { isPro in
                let profile = viewModel.buildProfile()
                onComplete(profile, viewModel.goalImageData, isPro)
            }
        }
    }
}
