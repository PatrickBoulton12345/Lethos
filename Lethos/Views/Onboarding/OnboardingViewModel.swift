import SwiftUI
import PhotosUI

enum OnboardingStep: Int, CaseIterable {
    case welcome
    case tellUsAboutYou
    // Photo path
    case photoAnalysing
    case photoResult         // "We think you're: X" (confidence >= 60%)
    // Photo path only: age + gender
    case manualAge
    case manualGender
    // Manual path
    case manualWeight
    case manualHeight
    case buildSelection      // Manual path always, photo path only if confidence < 60%
    // Converge
    case dietaryRequirements
    case goalPhysique
    case goalAnalysing
    case paywall
}

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var currentStep: OnboardingStep = .welcome
    @Published var navigationPath: [OnboardingStep] = []

    // User data
    @Published var weightKg: String = ""
    @Published var heightCm: String = ""
    @Published var age: String = ""
    @Published var useImperial = false
    @Published var selectedGender: Gender?
    @Published var selectedBodyType: BodyType?
    @Published var selectedDietary: Set<DietaryRequirement> = []
    @Published var otherDietaryText: String = ""

    // Photos
    @Published var selfieImageData: Data?
    @Published var goalImageData: Data?

    // AI results
    @Published var bodyAnalysis: BodyAnalysisResponse?
    @Published var isAnalysingSelfie = false
    @Published var isAnalysingGoal = false
    @Published var analysisError: String?

    // Path tracking
    @Published var usedPhotoPath = false
    @Published var aiConfidenceHigh = false

    // Whether build card expand-on-hold is enabled
    var allowBuildExpand: Bool {
        !usedPhotoPath || !aiConfidenceHigh
    }

    // MARK: - Navigation

    /// Tracks whether the last navigation was forward or backward, for transition direction.
    @Published var navigatingForward = true

    var resolvedStepPath: [OnboardingStep] {
        OnboardingStepConfig.resolvedStepPath(for: self)
    }

    var currentStepIndex: Int {
        resolvedStepPath.firstIndex(of: currentStep) ?? 0
    }

    func navigateTo(_ step: OnboardingStep) {
        navigatingForward = true
        navigationPath.append(step)
        currentStep = step
    }

    func goBack() {
        guard !navigationPath.isEmpty else { return }
        navigatingForward = false
        navigationPath.removeLast()
        currentStep = navigationPath.last ?? .welcome
    }

    // MARK: - Photo Path
    //
    // Flowchart: Upload → AI Analysis → (confidence >= 60%: photoResult) or (< 60%: buildSelection)
    //            → Age → Gender → Dietary → Goal Physique → Paywall
    //
    // The photo path asks age + gender AFTER the AI analysis.
    // Build selection only appears if confidence < 60% or API error.

    func analyseSelfie() async {
        guard let imageData = selfieImageData else { return }
        isAnalysingSelfie = true
        analysisError = nil
        usedPhotoPath = true
        navigateTo(.photoAnalysing)

        do {
            let result = try await OpenAIService.shared.analyseCurrentBody(imageData: imageData)
            bodyAnalysis = result

            if let category = result.buildCategory,
               let type = BodyType(rawValue: category) {
                selectedBodyType = type
            }

            if result.error != nil || result.confidencePercentage < 60 {
                // Low confidence → show build selection with AI's best guess pre-selected
                aiConfidenceHigh = false
                navigateTo(.buildSelection)
            } else {
                // High confidence → show result screen
                aiConfidenceHigh = true
                navigateTo(.photoResult)
            }
        } catch {
            // API error → show build selection as fallback
            analysisError = error.localizedDescription
            aiConfidenceHigh = false
            navigateTo(.buildSelection)
        }

        isAnalysingSelfie = false
    }

    func acceptPhotoResult() {
        // User confirmed AI's build assessment → continue photo path: age next
        navigateTo(.manualAge)
    }

    func rejectPhotoResult() {
        // User disagrees with AI → let them pick build, then continue photo path
        aiConfidenceHigh = false
        navigateTo(.buildSelection)
    }

    // MARK: - Manual Path
    //
    // Flowchart: Gender → Weight → Height → Build → Dietary → Goal Physique → Paywall

    func startManualEntry() {
        usedPhotoPath = false
        navigateTo(.manualGender)
    }

    func submitWeight() {
        navigateTo(.manualHeight)
    }

    func submitHeight() {
        navigateTo(.buildSelection)
    }

    // MARK: - Shared Steps

    func submitBuild() {
        if usedPhotoPath {
            // Photo path: after build selection → age → gender → dietary
            navigateTo(.manualAge)
        } else {
            // Manual path: after build → skip age/gender → dietary
            navigateTo(.dietaryRequirements)
        }
    }

    func submitAge() {
        navigateTo(.manualGender)
    }

    func submitGender() {
        if usedPhotoPath {
            navigateTo(.dietaryRequirements)
        } else {
            navigateTo(.manualWeight)
        }
    }

    func submitDietary() {
        navigateTo(.goalPhysique)
    }

    func submitGoalPhoto() {
        navigateTo(.paywall)
    }

    // MARK: - Build Profile

    func buildProfile() -> UserProfile {
        var profile = UserProfile.empty
        profile.weightKg = Double(weightKg)
        profile.heightCm = Int(heightCm)
        profile.age = Int(age)
        profile.gender = selectedGender?.rawValue
        profile.currentBodyType = selectedBodyType?.rawValue
        profile.dietaryRequirements = selectedDietary.map { $0.rawValue }
        if selectedDietary.contains(.other) && !otherDietaryText.isEmpty {
            profile.dietaryRequirements.append(otherDietaryText)
        }
        return profile
    }
}
