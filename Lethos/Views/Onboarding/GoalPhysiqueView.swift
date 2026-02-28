import SwiftUI
import PhotosUI

struct GoalPhysiqueView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var selectedItem: PhotosPickerItem?

    var body: some View {
        VStack(spacing: LethoSpacing.sectionSpacing) {
            Spacer()

            VStack(spacing: 12) {
                Text("Now show us your goal")
                    .font(LethoFont.headline(28))
                    .foregroundColor(.white)

                Text("Upload a photo of the physique you want to achieve")
                    .font(LethoFont.body(15))
                    .foregroundColor(.lethosSecondary)
                    .multilineTextAlignment(.center)
            }

            if let data = viewModel.goalImageData,
               let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 280)
                    .clipShape(RoundedRectangle(cornerRadius: LethoSpacing.cardCornerRadius))
                    .overlay(
                        RoundedRectangle(cornerRadius: LethoSpacing.cardCornerRadius)
                            .stroke(Color.lethosBorderSelected, lineWidth: 1)
                    )
            } else {
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.lethosGreenDark)
                                .frame(width: 64, height: 64)
                            Image(systemName: "photo.badge.plus")
                                .font(.system(size: 28))
                                .foregroundColor(.lethosGreenAccent)
                        }

                        Text("Tap to upload")
                            .font(LethoFont.body())
                            .foregroundColor(.lethosSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .background(Color.lethosCard)
                    .clipShape(RoundedRectangle(cornerRadius: LethoSpacing.cardCornerRadius))
                    .overlay(
                        RoundedRectangle(cornerRadius: LethoSpacing.cardCornerRadius)
                            .stroke(Color.lethosBorder, lineWidth: 1)
                    )
                }
            }

            if viewModel.goalImageData != nil {
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    Text("Change photo")
                        .font(LethoFont.body(15))
                        .foregroundColor(.lethosSecondary)
                        .underline()
                }
                .frame(minHeight: LethoSpacing.minTapTarget)
            }

            Spacer()
        }
        .padding(.horizontal, LethoSpacing.screenPadding)
        .onChange(of: selectedItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    viewModel.goalImageData = data
                }
            }
        }
    }
}
