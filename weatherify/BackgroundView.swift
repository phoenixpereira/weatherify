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
            return isNight ? [Color.black, Color.gray] : [Color.blue, Color.orange]
        case "Partly cloudy":
            return isNight ? [Color.gray, Color.black] : [Color.gray, Color.blue]
        case "Rainy":
            return [Color.gray, Color.blue.opacity(0.7)]
        case "Snowy":
            return [Color.white, Color.blue.opacity(0.5)]
        case "Thunderstorm":
            return [Color.black, Color.purple]
        default:
            return isNight ? [Color.black, Color.gray] : [Color.blue, Color.purple]
        }
    }
}
