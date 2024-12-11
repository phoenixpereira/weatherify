//
//  WeatherWeekView.swift
//  weatherify
//
//  Created by Phoenix Pereira on 11/12/2024.
//


import SwiftUI
import CoreLocation
import CoreLocationUI

struct WeatherWeekView: View {
    var dayOfWeek: String
    var imageName: String
    var temperature: Int
    
    var body: some View {
        HStack {
            Text(dayOfWeek)
                .font(.system(size: 16, weight: .medium, design: .default))
                .foregroundStyle(.white)
            
            Image(systemName: imageName)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 40)
            
            Text("\(temperature)°")
                .font(.system(size: 28, weight: .medium))
                .foregroundStyle(.white)
        }
        .padding(16)
    }
}