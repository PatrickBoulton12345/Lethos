import SwiftUI

// MARK: - Button Style (for Buttons wrapping tappable cards)

struct GlowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .shadow(
                color: configuration.isPressed ? Color.lethosGreenAccent.opacity(0.5) : .clear,
                radius: configuration.isPressed ? 12 : 0
            )
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Static glow (for non-button selected states)

struct GreenGlowModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
    }
}

extension View {
    func greenGlow() -> some View {
        modifier(GreenGlowModifier())
    }

    func glowButtonStyle() -> some View {
        self.buttonStyle(GlowButtonStyle())
    }
}
