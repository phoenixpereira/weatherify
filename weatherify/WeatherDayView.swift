//
//  WeatherDayView.swift
//  weatherify
//
//  Created by Phoenix Pereira on 11/12/2024.
//


import SwiftUI
import CoreLocation
import CoreLocationUI

struct WeatherDayView: View {
    var imageName: String
    var temperature: Int
    var minTemperature: Int
    var maxTemperature: Int
    var condition: String
    var geometry: GeometryProxy

    var body: some View {
        HStack(spacing: geometry.size.height * 0.05) {
            Image(systemName: imageName)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: geometry.size.width * 0.25, height: geometry.size.width * 0.25)
                
            VStack(spacing: 5) {
                Text("\(temperature)°")
                    .font(.system(size: geometry.size.width * 0.1, weight: .medium))
                    .foregroundColor(.white)
                
                Text(condition)
                    .font(.system(size: geometry.size.width * 0.05))
                    .foregroundColor(.white)
                    .padding(.top, 5)
                
                HStack(spacing: 5) {
                    VStack {
                        Text("L: \(minTemperature)°")
                            .font(.system(size: geometry.size.width * 0.05))
                            .foregroundColor(.white)
                    }
                    
                    VStack {
                        Text("H: \(maxTemperature)°")
                            .font(.system(size: geometry.size.width * 0.05))
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .padding(.bottom, geometry.size.height * 0.05)
    }
}