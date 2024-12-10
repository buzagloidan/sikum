import SwiftUI

enum Theme {
    // Brand Colors
    static let primary = Color(hex: "2E4FE6")      // Deep blue
    static let secondary = Color(hex: "FF6B6B")    // Coral
    static let accent = Color(hex: "4ECDC4")       // Teal
    
    // Modern, vibrant gradients
    static let gradient1 = LinearGradient(
        colors: [
            Color(hex: "FF6B6B"), // Coral
            Color(hex: "4ECDC4")  // Teal
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let gradient2 = LinearGradient(
        colors: [
            Color(hex: "A8E6CF"), // Mint
            Color(hex: "3D84A8")  // Ocean Blue
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Accent colors
    static let accent1 = Color(hex: "FF6B6B") // Coral
    static let accent2 = Color(hex: "4ECDC4") // Teal
    static let accent3 = Color(hex: "95E1D3") // Mint
    
    // Background colors
    static let background = Color(hex: "F8F9FA")
    static let cardBackground = Color.white
    
    // Text colors
    static let textPrimary = Color(hex: "2D3436")
    static let textSecondary = Color(hex: "636E72")
    
    // Status colors
    static let success = Color(hex: "00B894")
    static let error = Color(hex: "FF7675")
    
    // Card styles
    static let cardShadow = Color.black.opacity(0.1)
    static let cardRadius: CGFloat = 20
    
    // Custom button style
    static func mainButton(_ content: String) -> some View {
        Text(content)
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(gradient1)
            .cornerRadius(15)
            .shadow(color: cardShadow, radius: 10, x: 0, y: 5)
    }
    
    // Custom card style
    static func card<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding()
            .background(cardBackground)
            .cornerRadius(cardRadius)
            .shadow(color: cardShadow, radius: 15, x: 0, y: 10)
    }
}

// Helper for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// Custom button style
struct GradientButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Theme.gradient1)
            .foregroundColor(.white)
            .cornerRadius(15)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// View extension for common modifiers
extension View {
    func cardStyle() -> some View {
        modifier(CardModifier())
    }
}

// Card modifier
struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Theme.cardBackground)
            .cornerRadius(Theme.cardRadius)
            .shadow(color: Theme.cardShadow, radius: 15, x: 0, y: 10)
    }
}
