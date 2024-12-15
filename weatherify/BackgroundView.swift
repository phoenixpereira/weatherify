//
//  BackgroundView.swift
//  weatherify
//
//  Created by Phoenix Pereira on 10/12/2024.
//

import SwiftUI

struct BackgroundView: View {
    var weatherCondition: String
    @Binding var isNight: Bool
    @Environment(\.colorScheme) var colorScheme // Detect light/dark mode

    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: adjustedBackgroundColors(for: weatherCondition)),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    func adjustedBackgroundColors(for condition: String) -> [Color] {
        let baseColors = backgroundColors(for: condition)
        
        // Adjust colors if system is in dark mode
        if colorScheme == .dark {
            return baseColors.map { lightenColor($0, amount: 0.25) }
        } else {
            return baseColors
        }
    }

    func lightenColor(_ color: Color, amount: Double) -> Color {
        // Lighten by blending the color closer to white
        Color(
            red: lerp(color.components.red, 1.0, amount),
            green: lerp(color.components.green, 1.0, amount),
            blue: lerp(color.components.blue, 1.0, amount)
        )
    }

    func lerp(_ a: Double, _ b: Double, _ t: Double) -> Double {
        // Linear interpolation function to blend values
        return a + (b - a) * t
    }

    func backgroundColors(for condition: String) -> [Color] {
        switch condition {
            case "Clear sky":
                return isNight ? [Color.gray.opacity(0.5), Color.black] : [Color.orange.opacity(0.75), Color.blue]
            case "Partly cloudy":
                return isNight ? [Color.blue.opacity(0.75), Color.black] : [Color.blue.opacity(0.5), Color.black.opacity(0.5)]
            case "Rainy":
                return isNight ? [Color.gray, Color.black] : [Color.gray, Color.blue]
            case "Rain showers":
                return isNight ? [Color.gray.opacity(0.75), Color.black] : [Color.gray.opacity(0.75), Color.blue]
            case "Snowy":
                return isNight ? [Color.white, Color.gray] : [Color.gray.opacity(0.5), Color.gray]
            case "Thunderstorm":
                return isNight ? [Color.purple, Color.black] : [Color.purple, Color.gray]
            default:
                return isNight ? [Color.gray, Color.black] : [Color.orange, Color.blue]
        }
    }
}

extension Color {
    /// Extract RGB components from a Color
    var components: (red: Double, green: Double, blue: Double, opacity: Double) {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return (Double(red), Double(green), Double(blue), Double(alpha))
    }
}
