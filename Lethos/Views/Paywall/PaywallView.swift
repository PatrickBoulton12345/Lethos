import SwiftUI

struct PaywallView: View {
    let onComplete: (Bool) -> Void
    @State private var selectedPlan: PricingPlan = .monthly

    enum PricingPlan {
        case monthly, yearly
    }

    var body: some View {
        ScrollView {
            VStack(spacing: LethoSpacing.sectionSpacing) {
                // Headline
                VStack(spacing: 4) {
                    Text("To see your full")
                        .font(LethoFont.headline(28))
                        .foregroundColor(.white)

                    Text("PERSONALISED")
                        .font(.system(size: 34, weight: .bold).italic())
                        .foregroundStyle(LinearGradient.lethosGreen)

                    Text("workout plan")
                        .font(LethoFont.headline(28))
                        .foregroundColor(.white)
                }
                .padding(.top, 40)

                // Feature bullets
                VStack(alignment: .leading, spacing: 16) {
                    FeatureBullet(icon: "calendar.badge.checkmark", text: "Weekly check-ins with AI coaching")
                    FeatureBullet(icon: "fork.knife", text: "Personalised meal plan")
                    FeatureBullet(icon: "xmark.circle", text: "Cancel anytime")
                }
                .padding(.horizontal, 8)

                // Pricing cards
                VStack(spacing: 12) {
                    // Monthly
                    Button {
                        selectedPlan = .monthly
                    } label: {
                        GlowCard(isSelected: selectedPlan == .monthly) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Monthly")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.white)
                                    Text("£7.99/month")
                                        .font(LethoFont.body())
                                        .foregroundColor(.lethosSecondary)
                                }
                                Spacer()
                                if selectedPlan == .monthly {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.lethosGreenAccent)
                                        .font(.system(size: 24))
                                }
                            }
                        }
                    }

                    // Yearly
                    Button {
                        selectedPlan = .yearly
                    } label: {
                        GlowCard(isSelected: selectedPlan == .yearly) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Yearly")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.white)
                                    Text("£80/year")
                                        .font(LethoFont.body())
                                        .foregroundColor(.lethosSecondary)
                                }
                                Spacer()

                                Text("SAVE £15")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.lethosGreenAccent)
                                    .clipShape(Capsule())

                                if selectedPlan == .yearly {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.lethosGreenAccent)
                                        .font(.system(size: 24))
                                        .padding(.leading, 4)
                                }
                            }
                        }
                    }
                }

                // CTA
                OnboardingContinueButton(title: "START PRO") {
                    onComplete(true)
                }

                // Secondary actions
                VStack(spacing: 12) {
                    Button {
                        // Restore purchases — placeholder for StoreKit
                    } label: {
                        Text("Restore Purchases")
                            .font(LethoFont.body(15))
                            .foregroundColor(.lethosSecondary)
                    }
                    .frame(minHeight: LethoSpacing.minTapTarget)

                    Button {
                        onComplete(false)
                    } label: {
                        Text("Skip for now")
                            .font(LethoFont.body(15))
                            .foregroundColor(.lethosFinePrint)
                            .underline()
                    }
                    .frame(minHeight: LethoSpacing.minTapTarget)
                }
                .padding(.bottom, 40)
            }
            .padding(.horizontal, LethoSpacing.screenPadding)
        }
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - Feature Bullet

private struct FeatureBullet: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.lethosGreenDark)
                    .frame(width: LethoSpacing.iconCircleSize, height: LethoSpacing.iconCircleSize)
                Image(systemName: icon)
                    .foregroundColor(.lethosGreenAccent)
                    .font(.system(size: 18))
            }

            Text(text)
                .font(LethoFont.body())
                .foregroundColor(.white)
        }
    }
}
