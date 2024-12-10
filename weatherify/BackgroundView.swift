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
        let gradientColors = gradientColorsForCondition(weatherCondition: weatherCondition, isNight: isNight)
        LinearGradient(
            gradient: Gradient(colors: gradientColors),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private func gradientColorsForCondition(weatherCondition: String, isNight: Bool) -> [Color] {
        switch weatherCondition {
        case "Clear sky":
            return isNight ? [.black, .blue] : [.yellow, .blue]
        case "Partly cloudy":
            return isNight ? [.black, .gray] : [.gray, .blue]
        case "Rainy":
            return isNight ? [.black, .gray] : [.gray, .blue]
        case "Snowy":
            return isNight ? [.black, .gray] : [.gray, .white]
        case "Thunderstorm":
            return isNight ? [.black, .purple] : [.gray, .purple]
        default:
            return isNight ? [.black, .gray] : [.gray, .blue]
        }
    }
}
