//
//  WeatherWeekView.swift
//  weatherify
//
//  Created by Phoenix Pereira on 11/12/2024.
//

import SwiftUI

struct WeatherWeekView: View {
    var dayOfWeek: String
    var imageName: String
    var maxTemperature: Int
    var minTemperature: Int
    var precipitationChance: Int

    var body: some View {
        VStack(spacing: 8) {
            Text(dayOfWeek)
                .font(.system(size: 16, weight: .medium, design: .default))
                .foregroundStyle(.white)
            
            Image(systemName: imageName)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 40)
            
            // Precipitation text is hidden if the chance is 0
            if precipitationChance > 0 {
                Text("\(precipitationChance)%")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.blue)
            } else {
                Text(" ") // Empty text to reserve the same height
                    .font(.system(size: 16, weight: .medium))
            }
            
            VStack(spacing: 4) {
                Text("\(maxTemperature)°")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(.white)
                
                Text("\(minTemperature)°")
                    .font(.system(size: 16, weight: .light))
                    .foregroundStyle(.white)
            }
        }
        .frame(width: 80, height: 180)
        .background(.ultraThinMaterial)
        .cornerRadius(24)
    }
}
