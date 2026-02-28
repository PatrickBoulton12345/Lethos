import SwiftUI

struct PageDotsView: View {
    let totalSteps: Int
    let currentIndex: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<totalSteps, id: \.self) { index in
                if index == currentIndex {
                    Capsule()
                        .fill(Color.white)
                        .frame(width: 24, height: 8)
                } else {
                    Circle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: currentIndex)
    }
}
