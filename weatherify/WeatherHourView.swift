//
//  WeatherHourView.swift
//  weatherify
//
//  Created by Phoenix Pereira on 11/12/2024.
//

import SwiftUI

struct WeatherHourView: View {
    var time: String
    var imageName: String
    var temperature: Int
    
    var body: some View {
        VStack(spacing: 8) {
            Text(time)
                .font(.system(size: 16, weight: .medium, design: .default))
                .foregroundStyle(.white)
            
            Image(systemName: imageName)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 40)
            
            Text("\(temperature)°")
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(.white)
        }
        .frame(width: 80, height: 140)
        .background(.ultraThinMaterial)
        .cornerRadius(24)
    }
}
