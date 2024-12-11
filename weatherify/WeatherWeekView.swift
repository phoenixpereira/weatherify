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
    var maxTemperature: Int
    var minTemperature: Int
    
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
            
            VStack {
                Text("\(maxTemperature)°")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(.white)
                
                Text("\(minTemperature)°")
                    .font(.system(size: 16, weight: .light))
                    .foregroundStyle(.white)
            }
        }
        .padding(16)
    }
}
