import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appViewModel: AppViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: LethoSpacing.sectionSpacing) {
                // Greeting
                VStack(alignment: .leading, spacing: 4) {
                    Text("Hey \(appViewModel.profile.email?.components(separatedBy: "@").first ?? "there")")
                        .font(LethoFont.headline(28))
                        .foregroundColor(.lethosPrimary)

                    Text(dateString)
                        .font(LethoFont.body(15))
                        .foregroundColor(.lethosSecondary)
                }

                if !appViewModel.profile.isPro {
                    // Locked state
                    lockedCard
                } else if appViewModel.isLoadingPlan {
                    // Analysing state
                    analysingCard
                } else if let plan = appViewModel.workoutPlan?.planJson {
                    // Today's workout
                    todayWorkoutCard(plan)

                    // Goal card
                    if let analysis = appViewModel.physiqueAnalysis?.analysisJson {
                        goalCard(analysis)
                    }

                    // Weekly compliance
                    weeklyComplianceCard
                } else {
                    // No plan yet
                    noPlanCard
                }
            }
            .padding(.horizontal, LethoSpacing.screenPadding)
            .padding(.top, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.lethosBlack)
    }

    // MARK: - Cards

    private var lockedCard: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.fill")
                .font(.system(size: 32))
                .foregroundColor(.lethosGreenAccent)

            Text("Upgrade to PRO to unlock your personalised plan")
                .font(LethoFont.body())
                .foregroundColor(.lethosSecondary)
                .multilineTextAlignment(.center)

            GradientButton(title: "Upgrade") {
                appViewModel.showPaywall = true
            }
        }
        .padding(LethoSpacing.cardPadding)
        .background(Color.lethosCard)
        .clipShape(RoundedRectangle(cornerRadius: LethoSpacing.cardCornerRadius))
    }

    private var analysingCard: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(.lethosGreenAccent)
                .scaleEffect(1.2)

            Text("Analysing your goal...")
                .font(LethoFont.body())
                .foregroundColor(.lethosSecondary)

            Text("This may take up to 30 seconds")
                .font(LethoFont.body(14))
                .foregroundColor(.lethosFinePrint)
        }
        .frame(maxWidth: .infinity)
        .padding(LethoSpacing.cardPadding)
        .background(Color.lethosCard)
        .clipShape(RoundedRectangle(cornerRadius: LethoSpacing.cardCornerRadius))
    }

    private func todayWorkoutCard(_ plan: WorkoutPlanResponse) -> some View {
        let todayIndex = Calendar.current.component(.weekday, from: Date()) - 1
        let schedule = plan.weeklySchedule ?? []
        let todaySession = schedule.indices.contains(todayIndex) ? schedule[todayIndex] : schedule.first

        return VStack(alignment: .leading, spacing: 12) {
            Text("Today's Workout")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.lethosGreenAccent)
                .textCase(.uppercase)

            if let session = todaySession, session.isRestDay != true {
                Text(session.sessionName ?? "Training Day")
                    .font(LethoFont.headline(22))
                    .foregroundColor(.lethosPrimary)

                HStack(spacing: 16) {
                    Label("\(session.exercises?.count ?? 0) exercises", systemImage: "dumbbell.fill")
                    Label("\(session.estimatedDurationMinutes ?? 45) min", systemImage: "clock.fill")
                }
                .font(LethoFont.body(14))
                .foregroundColor(.lethosSecondary)

                if let goal = session.sessionGoal {
                    Text(goal)
                        .font(LethoFont.body(15))
                        .foregroundColor(.lethosSecondary)
                }

                GradientButton(title: "Start Workout") {
                    appViewModel.startWorkout(dayNumber: todaySession?.day ?? 1)
                }
                .padding(.top, 4)
            } else {
                Text("Rest Day")
                    .font(LethoFont.headline(22))
                    .foregroundColor(.lethosPrimary)

                Text(todaySession?.description ?? "Light walking, stretching, or foam rolling")
                    .font(LethoFont.body(15))
                    .foregroundColor(.lethosSecondary)
            }
        }
        .padding(LethoSpacing.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.lethosCard)
        .clipShape(RoundedRectangle(cornerRadius: LethoSpacing.cardCornerRadius))
    }

    private func goalCard(_ analysis: PhysiqueAnalysisResponse) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Goal")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.lethosGreenAccent)
                .textCase(.uppercase)

            if let summary = analysis.physiqueSummary {
                Text(summary)
                    .font(LethoFont.body(15))
                    .foregroundColor(.lethosSecondary)
            }

            HStack(spacing: 20) {
                if let pct = analysis.percentageDifferenceFromCurrent {
                    VStack(spacing: 4) {
                        Text("\(pct)%")
                            .font(LethoFont.headline(28))
                            .foregroundColor(.lethosGreenAccent)
                        Text("to go")
                            .font(LethoFont.body(13))
                            .foregroundColor(.lethosFinePrint)
                    }
                }

                if let timeline = analysis.realisticTimeline {
                    VStack(spacing: 4) {
                        Text("\(timeline.estimatedMonthsMinimum ?? 0)-\(timeline.estimatedMonthsMaximum ?? 0)")
                            .font(LethoFont.headline(28))
                            .foregroundColor(.lethosPrimary)
                        Text("months")
                            .font(LethoFont.body(13))
                            .foregroundColor(.lethosFinePrint)
                    }
                }
            }
        }
        .padding(LethoSpacing.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.lethosCard)
        .clipShape(RoundedRectangle(cornerRadius: LethoSpacing.cardCornerRadius))
    }

    private var weeklyComplianceCard: some View {
        let completed = appViewModel.completionsThisWeek.count
        let planned = appViewModel.workoutPlan?.planJson?.planOverview?.sessionsPerWeek ?? 3
        let progress = planned > 0 ? Double(completed) / Double(planned) : 0

        return VStack(alignment: .leading, spacing: 12) {
            Text("This Week")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.lethosGreenAccent)
                .textCase(.uppercase)

            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .stroke(Color.lethosBorder, lineWidth: 6)
                        .frame(width: 60, height: 60)
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(Color.lethosGreenAccent, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(-90))
                    Text("\(completed)/\(planned)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.lethosPrimary)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("\(completed) of \(planned) workouts done")
                        .font(LethoFont.body())
                        .foregroundColor(.lethosPrimary)

                    Text(completed >= planned ? "Great work this week!" : "Keep going!")
                        .font(LethoFont.body(14))
                        .foregroundColor(.lethosSecondary)
                }
            }
        }
        .padding(LethoSpacing.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.lethosCard)
        .clipShape(RoundedRectangle(cornerRadius: LethoSpacing.cardCornerRadius))
    }

    private var noPlanCard: some View {
        VStack(spacing: 12) {
            Text("No workout plan yet")
                .font(LethoFont.body())
                .foregroundColor(.lethosSecondary)

            GradientButton(title: "Generate Plan") {
                Task { await appViewModel.generatePlan() }
            }
        }
        .padding(LethoSpacing.cardPadding)
        .background(Color.lethosCard)
        .clipShape(RoundedRectangle(cornerRadius: LethoSpacing.cardCornerRadius))
    }

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM"
        return formatter.string(from: Date())
    }
}
