import SwiftUI
import PhotosUI

struct TellUsAboutYouView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var selectedItem: PhotosPickerItem?

    var body: some View {
        VStack(spacing: LethoSpacing.sectionSpacing) {
            Spacer()

            Text("Tell us about you")
                .font(LethoFont.headline())
                .foregroundColor(.white)

            VStack(spacing: 16) {
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    cardContent(
                        icon: "camera.fill",
                        title: "Upload a photo",
                        subtitle: "Our AI will assess your current build",
                        badge: "Best results"
                    )
                }
                .glowButtonStyle()
                .onChange(of: selectedItem) { _, newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                            viewModel.selfieImageData = data
                            await viewModel.analyseSelfie()
                        }
                    }
                }

                Button {
                    viewModel.startManualEntry()
                } label: {
                    cardContent(
                        icon: "pencil.line",
                        title: "Enter manually",
                        subtitle: "I'll fill in my details",
                        badge: nil
                    )
                }
                .glowButtonStyle()
            }

            Spacer()
        }
        .padding(.horizontal, LethoSpacing.screenPadding)
    }

    private func cardContent(icon: String, title: String, subtitle: String, badge: String?) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.lethosGreenDark)
                    .frame(width: LethoSpacing.iconCircleSize, height: LethoSpacing.iconCircleSize)
                Image(systemName: icon)
                    .foregroundColor(.lethosGreenAccent)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .font(LethoFont.headline(18))
                        .foregroundColor(.white)

                    if let badge = badge {
                        Text(badge)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.lethosGreenAccent)
                            .clipShape(Capsule())
                    }
                }

                Text(subtitle)
                    .font(LethoFont.body(15))
                    .foregroundColor(.lethosSecondary)
            }

            Spacer()
        }
        .padding(LethoSpacing.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.lethosCard)
        .clipShape(RoundedRectangle(cornerRadius: LethoSpacing.cardCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: LethoSpacing.cardCornerRadius)
                .stroke(Color.lethosBorder, lineWidth: 1)
        )
    }
}
