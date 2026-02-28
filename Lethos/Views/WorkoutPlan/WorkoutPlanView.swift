import SwiftUI

struct WorkoutPlanView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var expandedDay: Int?

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Plan header
                    if let overview = appViewModel.workoutPlan?.planJson?.planOverview {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(overview.planName ?? "Your Plan")
                                .font(LethoFont.headline(28))
                                .foregroundColor(.lethosPrimary)

                            Text(overview.trainingSplit ?? "")
                                .font(LethoFont.body(15))
                                .foregroundColor(.lethosGreenAccent)

                            if let rationale = overview.rationale {
                                Text(rationale)
                                    .font(LethoFont.body(15))
                                    .foregroundColor(.lethosSecondary)
                                    .padding(.top, 4)
                            }
                        }
                        .padding(.top, 20)
                    } else {
                        Text("Workout Plan")
                            .font(LethoFont.headline(28))
                            .foregroundColor(.lethosPrimary)
                            .padding(.top, 20)
                    }

                    // Disclaimer
                    if let disclaimer = appViewModel.workoutPlan?.planJson?.healthDisclaimer {
                        Text(disclaimer)
                            .font(LethoFont.body(13))
                            .foregroundColor(.lethosFinePrint)
                            .padding(12)
                            .background(Color.lethosCard)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    // Weekly schedule
                    if let schedule = appViewModel.workoutPlan?.planJson?.weeklySchedule {
                        ForEach(schedule) { day in
                            DaySection(
                                day: day,
                                isExpanded: expandedDay == day.day,
                                onTap: {
                                    withAnimation(.easeInOut(duration: 0.25)) {
                                        expandedDay = expandedDay == day.day ? nil : day.day
                                    }
                                },
                                onComplete: {
                                    appViewModel.startWorkout(dayNumber: day.day ?? 0)
                                }
                            )
                        }
                    }
                }
                .padding(.horizontal, LethoSpacing.screenPadding)
                .padding(.bottom, 40)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.lethosBlack)

            if !appViewModel.profile.isPro {
                LockedOverlay {
                    appViewModel.showPaywall = true
                }
            }
        }
    }
}

// MARK: - Day Section

private struct DaySection: View {
    let day: ScheduleDay
    let isExpanded: Bool
    let onTap: () -> Void
    let onComplete: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header
            Button(action: onTap) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(day.dayLabel ?? "Day \(day.day ?? 0)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.lethosPrimary)

                        if day.isRestDay == true {
                            Text("Rest Day")
                                .font(LethoFont.body(14))
                                .foregroundColor(.lethosSecondary)
                        } else {
                            Text(day.sessionName ?? "Training")
                                .font(LethoFont.body(14))
                                .foregroundColor(.lethosGreenAccent)
                        }
                    }

                    Spacer()

                    if day.isRestDay != true {
                        if let duration = day.estimatedDurationMinutes {
                            Text("\(duration) min")
                                .font(LethoFont.body(14))
                                .foregroundColor(.lethosSecondary)
                        }
                    }

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.lethosSecondary)
                        .font(.system(size: 14))
                }
                .padding(LethoSpacing.cardPadding)
                .background(Color.lethosCard)
                .clipShape(RoundedRectangle(cornerRadius: LethoSpacing.cardCornerRadius))
            }
            .buttonStyle(GlowButtonStyle())

            // Expanded content
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    if day.isRestDay == true {
                        Text(day.description ?? "Take it easy today. Light walking, stretching, or foam rolling.")
                            .font(LethoFont.body(15))
                            .foregroundColor(.lethosSecondary)
                    } else {
                        // Warmup
                        if let warmup = day.warmup, !warmup.isEmpty {
                            Text("WARMUP")
                                .font(LethoFont.headline(14))
                                .foregroundColor(.lethosPrimary)

                            ForEach(warmup) { exercise in
                                Text("• \(exercise.exerciseName ?? "") — \(exercise.notes ?? "")")
                                    .font(LethoFont.body(14))
                                    .foregroundColor(.lethosSecondary)
                            }
                        }

                        // Main exercises
                        if let exercises = day.exercises {
                            ForEach(exercises) { exercise in
                                ExerciseRow(exercise: exercise)
                            }
                        }

                        // Cooldown
                        if let cooldown = day.cooldown, !cooldown.isEmpty {
                            Text("COOLDOWN")
                                .font(LethoFont.headline(14))
                                .foregroundColor(.lethosPrimary)
                                .padding(.top, 8)

                            ForEach(cooldown) { exercise in
                                Text("• \(exercise.exerciseName ?? "") — \(exercise.notes ?? "")")
                                    .font(LethoFont.body(14))
                                    .foregroundColor(.lethosSecondary)
                            }
                        }

                        // Complete button
                        GradientButton(title: "Complete Workout") {
                            onComplete()
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(LethoSpacing.cardPadding)
                .background(Color.lethosCard.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: LethoSpacing.cardCornerRadius))
                .padding(.top, -8)
            }
        }
    }
}

// MARK: - Exercise Row

private struct ExerciseRow: View {
    let exercise: WorkoutExercise

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(exercise.exerciseName ?? "Exercise")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.lethosPrimary)

                Spacer()

                Text("\(exercise.sets ?? 3) × \(exercise.reps ?? "10")")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.lethosGreenAccent)
            }

            if let primary = exercise.musclesTargeted?.primary, !primary.isEmpty {
                Text(primary.joined(separator: ", "))
                    .font(LethoFont.body(13))
                    .foregroundColor(.lethosGreenAccent)
            }

            if let why = exercise.whyThisExercise {
                Text(why)
                    .font(LethoFont.body(14))
                    .foregroundColor(.lethosSecondary)
            }

            if let guide = exercise.startingWeightGuide {
                HStack(spacing: 12) {
                    if let male = guide.maleBeginner {
                        Label(male, systemImage: "scalemass.fill")
                            .font(LethoFont.body(12))
                            .foregroundColor(.lethosFinePrint)
                    }
                    if let female = guide.femaleBeginner {
                        Label(female, systemImage: "scalemass.fill")
                            .font(LethoFont.body(12))
                            .foregroundColor(.lethosFinePrint)
                    }
                }
            }

            Divider()
                .overlay(Color.lethosBorder)
        }
        .padding(.vertical, 4)
    }
}
