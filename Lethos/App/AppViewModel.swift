import SwiftUI

@MainActor
final class AppViewModel: ObservableObject {
    // MARK: - State

    @Published var isOnboarding = true
    @Published var showPaywall = false
    @Published var profile = UserProfile.empty
    @Published var physiqueAnalysis: StoredPhysiqueAnalysis?
    @Published var workoutPlan: StoredWorkoutPlan?
    @Published var checkins: [WeeklyCheckin] = []
    @Published var completionsThisWeek: [WorkoutCompletion] = []
    @Published var isLoadingPlan = false
    @Published var errorMessage: String?

    // Onboarding data
    var goalImageData: Data?

    private let supabase = SupabaseService.shared
    private let openAI = OpenAIService.shared

    // MARK: - Auth

    func signUp(email: String, password: String) async {
        do {
            try await supabase.signUp(email: email, password: password)
            if let user = supabase.currentUser {
                self.profile = user
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signIn(email: String, password: String) async {
        do {
            try await supabase.signIn(email: email, password: password)
            if let user = supabase.currentUser {
                self.profile = user
                self.isOnboarding = false
                await loadUserData()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signOut() {
        supabase.signOut()
        profile = UserProfile.empty
        physiqueAnalysis = nil
        workoutPlan = nil
        checkins = []
        completionsThisWeek = []
        isOnboarding = true
    }

    // MARK: - Onboarding Complete

    func completeOnboarding(profile: UserProfile, goalImageData: Data?, isPro: Bool) async {
        var updatedProfile = profile
        updatedProfile.isPro = isPro
        self.profile = updatedProfile
        self.goalImageData = goalImageData
        self.isOnboarding = false

        // Save profile (silently fails if Supabase isn't configured yet)
        do {
            try await supabase.upsertProfile(updatedProfile)
        } catch {
            print("[Lethos] Profile save skipped: \(error.localizedDescription)")
        }

        // If PRO, fire AI calls (silently fails if backend isn't configured)
        if isPro {
            await runAIAnalysis()
        }
    }

    // MARK: - AI Analysis Pipeline (PRO only)

    func runAIAnalysis() async {
        guard profile.isPro else { return }
        guard let imageData = goalImageData else { return }
        isLoadingPlan = true

        // Step 1: Analyse goal physique via AI
        let analysis: PhysiqueAnalysisResponse
        do {
            analysis = try await openAI.analyseGoalPhysique(
                imageData: imageData,
                bodyType: profile.currentBodyType ?? "average",
                height: profile.heightCm ?? 175,
                weight: profile.weightKg ?? 75,
                age: profile.age ?? 25,
                gender: profile.gender ?? "PNTS"
            )
        } catch {
            print("[Lethos] Goal analysis failed: \(error)")
            errorMessage = "Could not analyse your goal photo. Please try again."
            isLoadingPlan = false
            return
        }

        // Persist analysis to Supabase (best-effort)
        var analysisId = UUID()
        do {
            let imagePath = "\(profile.id.uuidString)/goal_\(UUID().uuidString).jpg"
            let imageUrl = try await supabase.uploadImage(path: imagePath, imageData: imageData)

            let storedAnalysis = StoredPhysiqueAnalysis(
                id: analysisId,
                userId: profile.id,
                goalImageUrl: imageUrl,
                analysisJson: analysis,
                percentageDifference: analysis.percentageDifferenceFromCurrent,
                createdAt: Date()
            )
            try await supabase.savePhysiqueAnalysis(storedAnalysis)
            self.physiqueAnalysis = storedAnalysis
        } catch {
            // Supabase not configured — store in memory only
            print("[Lethos] Supabase save skipped: \(error.localizedDescription)")
            self.physiqueAnalysis = StoredPhysiqueAnalysis(
                id: analysisId,
                userId: profile.id,
                goalImageUrl: nil,
                analysisJson: analysis,
                percentageDifference: analysis.percentageDifferenceFromCurrent,
                createdAt: Date()
            )
        }

        // Step 2: Generate workout plan via AI
        do {
            let workoutPlanResponse = try await openAI.generateWorkoutPlan(
                physiqueAnalysis: analysis,
                height: profile.heightCm ?? 175,
                weight: profile.weightKg ?? 75,
                age: profile.age ?? 25,
                gender: profile.gender ?? "PNTS",
                dietaryRequirements: profile.dietaryRequirements
            )

            let storedPlan = StoredWorkoutPlan(
                id: UUID(),
                userId: profile.id,
                physiqueAnalysisId: analysisId,
                planJson: workoutPlanResponse,
                isActive: true,
                createdAt: Date()
            )

            // Persist to Supabase (best-effort)
            do {
                try await supabase.saveWorkoutPlan(storedPlan)
            } catch {
                print("[Lethos] Workout plan save skipped: \(error.localizedDescription)")
            }

            self.workoutPlan = storedPlan
        } catch {
            print("[Lethos] Workout plan generation failed: \(error.localizedDescription)")
            errorMessage = "Could not generate your workout plan. Please try again."
        }

        isLoadingPlan = false
    }

    func generatePlan() async {
        await runAIAnalysis()
    }

    // MARK: - Load Data

    func loadUserData() async {
        do {
            physiqueAnalysis = try await supabase.fetchLatestPhysiqueAnalysis(userId: profile.id)
            workoutPlan = try await supabase.fetchActiveWorkoutPlan(userId: profile.id)
            await loadCheckins()
            await loadCompletions()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func loadCheckins() async {
        do {
            checkins = try await supabase.fetchCheckins(userId: profile.id)
        } catch {
            // Silently fail for check-ins
        }
    }

    func loadCompletions() async {
        do {
            completionsThisWeek = try await supabase.fetchCompletionsThisWeek(userId: profile.id)
        } catch {
            // Silently fail
        }
    }

    // MARK: - Workout Completion

    func startWorkout(dayNumber: Int) {
        guard let planId = workoutPlan?.id else { return }
        let completion = WorkoutCompletion(
            id: UUID(),
            userId: profile.id,
            workoutPlanId: planId,
            dayNumber: dayNumber,
            completedAt: Date()
        )

        Task {
            do {
                try await supabase.saveCompletion(completion)
                completionsThisWeek.append(completion)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    // MARK: - Upgrade

    func upgradeToPro() async {
        profile.isPro = true
        do {
            try await supabase.updateProfile(profile)
        } catch {
            errorMessage = error.localizedDescription
        }
        await runAIAnalysis()
    }
}
