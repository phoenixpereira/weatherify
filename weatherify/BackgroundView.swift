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

    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: backgroundColors(for: weatherCondition)),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    func backgroundColors(for condition: String) -> [Color] {
        switch condition {
        case "Clear sky":
            return isNight ? [Color.gray.opacity(0.5), Color.black] : [Color.orange, Color.blue]
        case "Partly cloudy":
            return isNight ? [Color.blue.opacity(0.75), Color.black] : [Color.blue.opacity(0.75), Color.gray]
        case "Rainy":
            return isNight ? [Color.gray, Color.black] : [Color.gray, Color.blue]
        case "Snowy":
            return isNight ? [Color.white, Color.gray] : [Color.gray.opacity(0.5), Color.gray]
        case "Thunderstorm":
            return isNight ? [Color.purple, Color.black] : [Color.purple, Color.gray]
        default:
            return isNight ? [Color.gray, Color.black] : [Color.orange, Color.blue]
        }
    }
}
