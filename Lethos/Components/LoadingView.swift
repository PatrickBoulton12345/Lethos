import SwiftUI

struct LoadingView: View {
    let title: String
    let subtitle: String
    var accentColor: Color = .lethosGreenAccent

    @State private var rotation: Double = 0
    @State private var pulse = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            ZStack {
                Circle()
                    .stroke(Color.lethosCard, lineWidth: 4)
                    .frame(width: 80, height: 80)

                Circle()
                    .trim(from: 0, to: 0.3)
                    .stroke(
                        accentColor,
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(rotation))

                Image(systemName: "sparkles")
                    .font(.system(size: 28))
                    .foregroundColor(accentColor)
                    .scaleEffect(pulse ? 1.15 : 0.9)
            }

            VStack(spacing: 12) {
                Text(title)
                    .font(LethoFont.headline(24))
                    .foregroundColor(.white)

                Text(subtitle)
                    .font(LethoFont.body())
                    .foregroundColor(.lethosSecondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .padding(.horizontal, LethoSpacing.screenPadding)
        .onAppear {
            withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            withAnimation(.easeInOut(duration: 1).repeatForever()) {
                pulse = true
            }
        }
    }
}
