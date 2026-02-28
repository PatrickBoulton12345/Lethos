import SwiftUI

struct GradientButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(LethoFont.button())
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: LethoSpacing.buttonHeight)
                .background(
                    LinearGradient.lethosGreen
                )
                .clipShape(RoundedRectangle(cornerRadius: LethoSpacing.buttonCornerRadius))
                .shadow(color: Color.lethosGreen.opacity(0.4), radius: 12, y: 4)
        }
        .buttonStyle(GlowButtonStyle())
    }
}
