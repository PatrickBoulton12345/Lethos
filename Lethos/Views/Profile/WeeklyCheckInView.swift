import SwiftUI
import PhotosUI

struct WeeklyCheckInView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var photoItem: PhotosPickerItem?
    @State private var photoData: Data?
    @State private var weight = ""
    @State private var sessionsCompleted = ""
    @State private var energyLevel = 5.0
    @State private var notes = ""
    @State private var isSubmitting = false
    @State private var result: CheckInResponse?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Weekly Check-in")
                        .font(LethoFont.headline(28))
                        .foregroundColor(.lethosPrimary)

                    // Photo
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Progress Photo")
                            .font(LethoFont.headline(14))
                            .foregroundColor(.lethosPrimary)

                        PhotosPicker(selection: $photoItem, matching: .images) {
                            if let data = photoData, let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 200)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            } else {
                                HStack {
                                    Image(systemName: "camera.fill")
                                        .foregroundColor(.lethosGreenAccent)
                                    Text("Upload photo")
                                        .foregroundColor(.lethosSecondary)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 120)
                                .background(Color.lethosCard)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.lethosBorder, lineWidth: 1)
                                )
                            }
                        }
                    }

                    // Weight
                    fieldSection(title: "Current Weight (kg)") {
                        TextField("75.0", text: $weight)
                            .keyboardType(.decimalPad)
                            .font(LethoFont.body())
                            .foregroundColor(.lethosPrimary)
                            .padding(12)
                            .background(Color.lethosCard)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    // Sessions
                    fieldSection(title: "Workouts completed this week") {
                        TextField("3", text: $sessionsCompleted)
                            .keyboardType(.numberPad)
                            .font(LethoFont.body())
                            .foregroundColor(.lethosPrimary)
                            .padding(12)
                            .background(Color.lethosCard)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    // Energy
                    fieldSection(title: "Energy Level: \(Int(energyLevel))/10") {
                        Slider(value: $energyLevel, in: 1...10, step: 1)
                            .tint(.lethosGreenAccent)
                    }

                    // Notes
                    fieldSection(title: "How do you feel?") {
                        TextField("Any notes...", text: $notes, axis: .vertical)
                            .font(LethoFont.body())
                            .foregroundColor(.lethosPrimary)
                            .lineLimit(3...6)
                            .padding(12)
                            .background(Color.lethosCard)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    // Result
                    if let result = result {
                        checkInResultCard(result)
                    }

                    // Submit
                    GradientButton(title: isSubmitting ? "Submitting..." : "Submit Check-in") {
                        Task { await submitCheckIn() }
                    }
                    .disabled(isSubmitting || weight.isEmpty)
                    .opacity(isSubmitting || weight.isEmpty ? 0.5 : 1)
                }
                .padding(.horizontal, LethoSpacing.screenPadding)
                .padding(.vertical, 20)
            }
            .background(Color.lethosBlack)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.lethosGreenAccent)
                }
            }
        }
        .onChange(of: photoItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    photoData = data
                }
            }
        }
    }

    @ViewBuilder
    private func fieldSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(LethoFont.headline(14))
                .foregroundColor(.lethosPrimary)
            content()
        }
    }

    private func checkInResultCard(_ result: CheckInResponse) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            if let headline = result.headline {
                Text(headline)
                    .font(LethoFont.headline(20))
                    .foregroundColor(.lethosPrimary)
            }

            if let changes = result.visibleChanges {
                Text(changes)
                    .font(LethoFont.body(15))
                    .foregroundColor(.lethosSecondary)
            }

            if let wins = result.wins, !wins.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Wins")
                        .font(LethoFont.headline(14))
                        .foregroundColor(.lethosPrimary)
                    ForEach(wins, id: \.self) { win in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.lethosGreenAccent)
                                .font(.system(size: 14))
                            Text(win)
                                .font(LethoFont.body(14))
                                .foregroundColor(.lethosSecondary)
                        }
                    }
                }
            }

            if let message = result.motivationMessage {
                Text(message)
                    .font(LethoFont.body(15))
                    .foregroundColor(.lethosGreenAccent)
                    .italic()
                    .padding(.top, 4)
            }

            if let pct = result.progressPercentageTowardGoal {
                HStack {
                    Text("Progress: \(pct)%")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.lethosPrimary)
                    Spacer()
                    if let weeks = result.estimatedWeeksRemaining {
                        Text("~\(weeks) weeks to go")
                            .font(LethoFont.body(14))
                            .foregroundColor(.lethosSecondary)
                    }
                }
            }
        }
        .padding(LethoSpacing.cardPadding)
        .background(Color.lethosCard)
        .clipShape(RoundedRectangle(cornerRadius: LethoSpacing.cardCornerRadius))
    }

    private func submitCheckIn() async {
        guard appViewModel.profile.isPro else { return }
        isSubmitting = true

        let goalAnalysis = appViewModel.physiqueAnalysis?.analysisJson ?? PhysiqueAnalysisResponse(
            physiqueSummary: nil, estimatedBodyFatPercentage: nil, buildType: nil,
            muscleEmphasis: nil, definitionLevel: nil, frame: nil,
            trainingRecommendation: nil, nutritionRecommendation: nil,
            realisticTimeline: nil, percentageDifferenceFromCurrent: nil, error: nil
        )

        let lastCheckin = appViewModel.checkins.first
        let weekNum = (lastCheckin?.weekNumber ?? 0) + 1
        let planned = appViewModel.workoutPlan?.planJson?.planOverview?.sessionsPerWeek ?? 3

        do {
            let response = try await OpenAIService.shared.weeklyCheckIn(
                currentPhotoData: photoData,
                previousPhotoData: nil,
                goalAnalysis: goalAnalysis,
                planOverview: appViewModel.workoutPlan?.planJson?.planOverview,
                weight: Double(weight) ?? 0,
                lastWeight: lastCheckin?.weightKg,
                startWeight: appViewModel.profile.weightKg,
                sessionsCompleted: Int(sessionsCompleted) ?? 0,
                sessionsPlanned: planned,
                energyLevel: Int(energyLevel),
                userNotes: notes,
                weekNumber: weekNum
            )
            self.result = response

            // Save to Supabase
            let checkin = WeeklyCheckin(
                id: UUID(),
                userId: appViewModel.profile.id,
                weekNumber: weekNum,
                photoUrl: nil,
                weightKg: Double(weight),
                sessionsCompleted: Int(sessionsCompleted),
                sessionsPlanned: planned,
                energyLevel: Int(energyLevel),
                userNotes: notes,
                aiResponseJson: response,
                progressPercentage: response.progressPercentageTowardGoal,
                createdAt: Date()
            )
            try await SupabaseService.shared.saveCheckin(checkin)
            await appViewModel.loadCheckins()
        } catch {
            // Show error inline
            self.result = CheckInResponse(
                overallAssessment: nil, headline: "Something went wrong",
                visibleChanges: nil, wins: nil, areasToImprove: nil,
                progressPercentageTowardGoal: nil, estimatedWeeksRemaining: nil,
                weightTrend: nil, trainingCompliance: nil, planAdjustments: nil,
                motivationMessage: error.localizedDescription, error: error.localizedDescription
            )
        }

        isSubmitting = false
    }
}
