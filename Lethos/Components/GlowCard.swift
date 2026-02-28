import SwiftUI

struct GlowCard<Content: View>: View {
    let isSelected: Bool
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .padding(LethoSpacing.cardPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isSelected ? Color.lethosCardSelected : Color.lethosCard)
            .clipShape(RoundedRectangle(cornerRadius: LethoSpacing.cardCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: LethoSpacing.cardCornerRadius)
                    .stroke(
                        isSelected ? Color.lethosBorderSelected : Color.lethosBorder,
                        lineWidth: 1
                    )
            )
            .shadow(
                color: isSelected ? Color.lethosGreenAccent.opacity(0.3) : .clear,
                radius: isSelected ? 8 : 0
            )
    }
}
