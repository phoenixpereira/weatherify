//
//  DetailedForecast.swift
//  weatherify
//
//  Created by Phoenix Pereira on 13/12/2024.
//

import SwiftUI
import CoreLocation
import CoreLocationUI

struct DetailedForecast: View {
    var geometry: GeometryProxy
    var weatherViewModel: WeatherViewModel
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                Spacer()
                
                // Hourly Forecast
                VStack {
                    Text("Hourly Forecast")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(.white)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(weatherViewModel.hourlyForecast, id: \.time) { hourlyWeather in
                                WeatherHourView(
                                    time: hourlyWeather.time,
                                    imageName: hourlyWeather.conditionImageName(),
                                    temperature: Int(hourlyWeather.temperature),
                                    precipitationChance: hourlyWeather.precipitationChance
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal, 10)
                
                // Weekly Forecast
                VStack {
                    Text("Weekly Forecast")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(.white)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(weatherViewModel.forecast, id: \.dayOfWeek) { weatherDay in
                                WeatherWeekView(
                                    dayOfWeek: weatherDay.dayOfWeek,
                                    imageName: weatherDay.conditionImageName(),
                                    maxTemperature: Int(weatherDay.maxTemperature),
                                    minTemperature: Int(weatherDay.minTemperature),
                                    precipitationChance: Int(weatherDay.precipitationChance)
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal, 10)
            }
        }
        .frame(height: geometry.size.height * 0.75)
        .background(.ultraThinMaterial)
        .cornerRadius(32)
    }
}
