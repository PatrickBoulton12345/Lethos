import SwiftUI

struct LockedOverlay: View {
    let onUpgrade: () -> Void

    var body: some View {
        ZStack {
            Color.lethosBlack.opacity(0.85)

            VStack(spacing: 20) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.lethosGreenAccent)

                Text("Upgrade to PRO")
                    .font(LethoFont.headline(24))
                    .foregroundColor(.lethosPrimary)

                Text("Unlock your personalised plan")
                    .font(LethoFont.body())
                    .foregroundColor(.lethosSecondary)

                GradientButton(title: "Upgrade") {
                    onUpgrade()
                }
                .padding(.horizontal, 40)
            }
        }
    }
}
