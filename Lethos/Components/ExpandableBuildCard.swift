import SwiftUI

struct ExpandableBuildCard: View {
    let bodyType: BodyType
    let isSelected: Bool
    let allowExpand: Bool
    let onTap: () -> Void

    @State private var isExpanded = false

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                Text(bodyType.displayName)
                    .font(LethoFont.headline(18))
                    .foregroundColor(.lethosPrimary)

                if isExpanded && allowExpand {
                    Text(bodyType.description)
                        .font(LethoFont.body(15))
                        .foregroundColor(.lethosSecondary)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
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
        .buttonStyle(GlowButtonStyle())
        .onLongPressGesture(minimumDuration: 0.4) {
            guard allowExpand else { return }
            withAnimation(.easeInOut(duration: 0.25)) {
                isExpanded.toggle()
            }
        }
    }
}
