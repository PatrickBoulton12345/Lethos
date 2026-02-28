import SwiftUI
import PhotosUI

struct ProfileView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var showCheckIn = false
    @State private var goalPhotoItem: PhotosPickerItem?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: LethoSpacing.sectionSpacing) {
                Text("Profile")
                    .font(LethoFont.headline(28))
                    .foregroundColor(.lethosPrimary)
                    .padding(.top, 20)

                // Stats card
                statsCard

                // Goal physique
                goalPhysiqueCard

                // Progress photos
                progressPhotosSection

                // Actions
                actionsSection
            }
            .padding(.horizontal, LethoSpacing.screenPadding)
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.lethosBlack)
        .sheet(isPresented: $showCheckIn) {
            WeeklyCheckInView()
                .environmentObject(appViewModel)
        }
    }

    // MARK: - Stats Card

    private var statsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("YOUR STATS")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.lethosGreenAccent)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                StatItem(label: "Height", value: "\(appViewModel.profile.heightCm ?? 0) cm")
                StatItem(label: "Weight", value: String(format: "%.1f kg", appViewModel.profile.weightKg ?? 0))
                StatItem(label: "Age", value: "\(appViewModel.profile.age ?? 0)")
            }

            HStack(spacing: 16) {
                StatItem(label: "Build", value: BodyType(rawValue: appViewModel.profile.currentBodyType ?? "")?.displayName ?? "—")
                StatItem(label: "Gender", value: Gender(rawValue: appViewModel.profile.gender ?? "")?.displayName ?? "—")
            }
        }
        .padding(LethoSpacing.cardPadding)
        .background(Color.lethosCard)
        .clipShape(RoundedRectangle(cornerRadius: LethoSpacing.cardCornerRadius))
    }

    // MARK: - Goal Physique Card

    private var goalPhysiqueCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("GOAL PHYSIQUE")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.lethosGreenAccent)

                Spacer()

                PhotosPicker(selection: $goalPhotoItem, matching: .images) {
                    Text("Change")
                        .font(LethoFont.body(14))
                        .foregroundColor(.lethosSecondary)
                        .underline()
                }
            }

            if let analysis = appViewModel.physiqueAnalysis?.analysisJson {
                if let summary = analysis.physiqueSummary {
                    Text(summary)
                        .font(LethoFont.body(15))
                        .foregroundColor(.lethosSecondary)
                }

                if let buildType = analysis.buildType {
                    Text("Target: \(buildType.capitalized)")
                        .font(LethoFont.body(14))
                        .foregroundColor(.lethosGreenAccent)
                }
            }

            // Dietary requirements
            if !appViewModel.profile.dietaryRequirements.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Dietary")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.lethosFinePrint)

                    FlowLayout(spacing: 8) {
                        ForEach(appViewModel.profile.dietaryRequirements, id: \.self) { req in
                            Text(req.replacingOccurrences(of: "_", with: " ").capitalized)
                                .font(LethoFont.body(12))
                                .foregroundColor(.lethosGreenAccent)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.lethosGreenDark.opacity(0.5))
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding(LethoSpacing.cardPadding)
        .background(Color.lethosCard)
        .clipShape(RoundedRectangle(cornerRadius: LethoSpacing.cardCornerRadius))
    }

    // MARK: - Progress Photos

    private var progressPhotosSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("PROGRESS PHOTOS")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.lethosGreenAccent)

                Spacer()

                Button {
                    showCheckIn = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                        Text("Check-in")
                    }
                    .font(LethoFont.body(14))
                    .foregroundColor(.lethosGreenAccent)
                }
            }

            if appViewModel.checkins.isEmpty {
                Text("No check-ins yet. Complete your first week and submit a progress photo!")
                    .font(LethoFont.body(15))
                    .foregroundColor(.lethosSecondary)
                    .padding(.vertical, 20)
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 8) {
                    ForEach(appViewModel.checkins) { checkin in
                        VStack(spacing: 4) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.lethosCard)
                                .aspectRatio(3/4, contentMode: .fit)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .foregroundColor(.lethosFinePrint)
                                )

                            Text("Week \(checkin.weekNumber)")
                                .font(LethoFont.body(11))
                                .foregroundColor(.lethosFinePrint)
                        }
                    }
                }
            }
        }
        .padding(LethoSpacing.cardPadding)
        .background(Color.lethosCard)
        .clipShape(RoundedRectangle(cornerRadius: LethoSpacing.cardCornerRadius))
    }

    // MARK: - Actions

    private var actionsSection: some View {
        VStack(spacing: 12) {
            if appViewModel.profile.isPro {
                Button {
                    Task { await appViewModel.generatePlan() }
                } label: {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Regenerate Plan")
                    }
                    .font(LethoFont.body())
                    .foregroundColor(.lethosGreenAccent)
                    .frame(maxWidth: .infinity)
                    .frame(height: LethoSpacing.buttonHeight)
                    .background(Color.lethosCard)
                    .clipShape(RoundedRectangle(cornerRadius: LethoSpacing.buttonCornerRadius))
                    .overlay(
                        RoundedRectangle(cornerRadius: LethoSpacing.buttonCornerRadius)
                            .stroke(Color.lethosBorder, lineWidth: 1)
                    )
                }
                .buttonStyle(GlowButtonStyle())
            }

            // Subscription status
            HStack {
                Text("Subscription")
                    .font(LethoFont.body())
                    .foregroundColor(.lethosSecondary)
                Spacer()
                Text(appViewModel.profile.isPro ? "PRO" : "Free")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(appViewModel.profile.isPro ? .lethosGreenAccent : .lethosFinePrint)
            }
            .padding(LethoSpacing.cardPadding)
            .background(Color.lethosCard)
            .clipShape(RoundedRectangle(cornerRadius: LethoSpacing.cardCornerRadius))

            // Sign out
            Button {
                appViewModel.signOut()
            } label: {
                Text("Sign Out")
                    .font(LethoFont.body())
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .frame(height: LethoSpacing.buttonHeight)
            }
        }
    }
}

// MARK: - Stat Item

private struct StatItem: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.lethosPrimary)
            Text(label)
                .font(LethoFont.body(12))
                .foregroundColor(.lethosFinePrint)
        }
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = layout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(proposal: proposal, subviews: subviews)
        for (index, placement) in result.placements.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + placement.x, y: bounds.minY + placement.y), proposal: .unspecified)
        }
    }

    private func layout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, placements: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var placements: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            placements.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }

        return (CGSize(width: maxWidth, height: y + rowHeight), placements)
    }
}
