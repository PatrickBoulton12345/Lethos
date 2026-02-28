import SwiftUI

@main
struct LethosApp: App {
    @StateObject private var appViewModel = AppViewModel()

    var body: some Scene {
        WindowGroup {
            Group {
                if appViewModel.isOnboarding {
                    OnboardingContainerView { profile, goalImageData, isPro in
                        appViewModel.goalImageData = goalImageData
                        Task {
                            await appViewModel.completeOnboarding(
                                profile: profile,
                                goalImageData: goalImageData,
                                isPro: isPro
                            )
                        }
                    }
                } else {
                    MainTabView()
                        .environmentObject(appViewModel)
                        .sheet(isPresented: $appViewModel.showPaywall) {
                            PaywallView { isPro in
                                if isPro {
                                    Task { await appViewModel.upgradeToPro() }
                                }
                                appViewModel.showPaywall = false
                            }
                        }
                }
            }
            .preferredColorScheme(.dark)
            .alert("Error", isPresented: .constant(appViewModel.errorMessage != nil)) {
                Button("OK") { appViewModel.errorMessage = nil }
            } message: {
                Text(appViewModel.errorMessage ?? "")
            }
        }
    }
}
