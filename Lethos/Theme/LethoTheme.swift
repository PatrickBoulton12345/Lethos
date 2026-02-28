import SwiftUI
import UIKit

// MARK: - UIColor hex helper

extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6:
            (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (0, 0, 0)
        }
        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: 1
        )
    }
}

// MARK: - Colors

extension Color {
    // Backgrounds — adaptive
    static let lethosBlack = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark ? .black : .systemBackground
    })
    static let lethosCard = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark ? UIColor(hex: "1A1A1A") : .secondarySystemBackground
    })
    static let lethosCardSelected = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark ? UIColor(hex: "0D1F17") : UIColor(hex: "E8F8F0")
    })

    // Borders — adaptive
    static let lethosBorder = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark ? UIColor(hex: "2A2A2A") : UIColor(hex: "E0E0E0")
    })
    static let lethosBorderSelected = Color(hex: "34D399")

    // Greens — brand colors, stay as-is
    static let lethosGreen = Color(hex: "22C55E")
    static let lethosGreenLight = Color(hex: "86EFAC")
    static let lethosGreenAccent = Color(hex: "34D399")
    static let lethosGreenDark = Color(hex: "166534")

    // Text — adaptive
    static let lethosPrimary = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark ? .white : .label
    })
    static let lethosSecondary = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark ? UIColor(hex: "A0A0A0") : UIColor(hex: "6B6B6B")
    })
    static let lethosFinePrint = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark ? UIColor(hex: "666666") : UIColor(hex: "8A8A8A")
    })

    // Onboarding step accent colors — brand, stay as-is
    static let onboardingTeal = Color(hex: "2DD4BF")
    static let onboardingBlue = Color(hex: "3B82F6")
    static let onboardingCyan = Color(hex: "06B6D4")
    static let onboardingSkyBlue = Color(hex: "38BDF8")
    static let onboardingPurple = Color(hex: "8B5CF6")
    static let onboardingViolet = Color(hex: "7C3AED")
    static let onboardingAmber = Color(hex: "F59E0B")
    static let onboardingIndigo = Color(hex: "6366F1")
    static let onboardingRose = Color(hex: "F43F5E")
    static let onboardingOrange = Color(hex: "F97316")
    static let onboardingGold = Color(hex: "EAB308")
    static let onboardingLime = Color(hex: "84CC16")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Gradients

extension LinearGradient {
    static let lethosGreen = LinearGradient(
        colors: [Color.lethosGreen, Color.lethosGreenLight],
        startPoint: .leading,
        endPoint: .trailing
    )
}

// MARK: - Typography

enum LethoFont {
    // Custom font name constants
    private static let clashSemibold = "ClashDisplay-Semibold"
    private static let clashMedium = "ClashDisplay-Medium"

    // ClashDisplay fonts (current)
    static func headline(_ size: CGFloat = 34) -> Font {
        .custom(clashSemibold, size: size)
    }

    static func onboardingTitle(_ size: CGFloat = 20) -> Font {
        .custom(clashMedium, size: size)
    }

    static func body(_ size: CGFloat = 17) -> Font {
        .system(size: size, weight: .regular)
    }

    static func button(_ size: CGFloat = 18) -> Font {
        .system(size: size, weight: .bold)
    }

    static func caption(_ size: CGFloat = 14) -> Font {
        .system(size: size, weight: .regular)
    }

    static func accentHeadline(_ size: CGFloat = 34) -> Font {
        .custom(clashSemibold, size: size)
    }

    // System font fallbacks (for revert)
    static func systemHeadline(_ size: CGFloat = 34) -> Font {
        .system(size: size, weight: .bold)
    }
}

// MARK: - Spacing

enum LethoSpacing {
    static let screenPadding: CGFloat = 20
    static let sectionSpacing: CGFloat = 32
    static let cardPadding: CGFloat = 24
    static let cardCornerRadius: CGFloat = 16
    static let buttonHeight: CGFloat = 56
    static let buttonCornerRadius: CGFloat = 16
    static let iconCircleSize: CGFloat = 44
    static let minTapTarget: CGFloat = 44
}
