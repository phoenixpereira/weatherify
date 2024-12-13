//
//  ContentView.swift
//  weatherify
//
//  Created by Phoenix Pereira on 8/12/2024.
//

import SwiftUI
import CoreLocation
import CoreLocationUI

struct ContentView: View {
    @StateObject private var weatherViewModel = WeatherViewModel()
    @State private var isNight = false
    @State private var searchQuery = ""

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                BackgroundView(weatherCondition: weatherViewModel.weather?.condition ?? "Clear sky", isNight: $isNight)

                // Main content
                VStack {
                    Spacer().frame(height: 60)
                    
                    CityTextView(cityName: weatherViewModel.cityName)
                    
                    // Weather status view
                    if let weather = weatherViewModel.weather {
                        WeatherDayView(
                            imageName: weather.conditionImageName(isNight: isNight),
                            temperature: Int(weather.temperature),
                            minTemperature: Int(weather.minTemperature),
                            maxTemperature: Int(weather.maxTemperature),
                            condition: weather.condition,
                            geometry: geometry
                        )
                    } else {
                        Text("Loading weather...")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(.white)
                    }

                    DetailedForecast(geometry: geometry, weatherViewModel: weatherViewModel)


                    Spacer()
                }

                Searchbox(searchQuery: searchQuery, geometry: geometry, weatherViewModel: weatherViewModel)
            }
            .onAppear {
                weatherViewModel.loadCities()
                weatherViewModel.startLocationUpdates()
            }
            .onChange(of: weatherViewModel.cityTimezone) { _ in
                determineDayOrNight()
            }
        }
    }

    private func determineDayOrNight() {
        guard let timezone = weatherViewModel.cityTimezone, let timeZone = TimeZone(identifier: timezone) else { return }
        let currentTime = Date()
        let localHour = Calendar.current.component(.hour, from: currentTime.toTimeZone(timeZone))

        // Assume night is between 8 PM to 6 AM
        isNight = localHour >= 20 || localHour < 6
    }
}


#Preview {
    ContentView()
}

// MARK: - Extensions

extension Date {
    func toTimeZone(_ timeZone: TimeZone) -> Date {
        let secondsFromGMT = timeZone.secondsFromGMT(for: self)
        return self.addingTimeInterval(TimeInterval(secondsFromGMT - TimeZone.current.secondsFromGMT(for: self)))
    }
}

extension Weather {
    func conditionImageName(isNight: Bool) -> String {
        switch condition {
        case "Clear sky": return isNight ? "moon.stars.fill" : "sun.max.fill"
        case "Partly cloudy": return isNight ? "cloud.moon.fill" : "cloud.sun.fill"
        case "Rainy": return "cloud.rain.fill"
        case "Snowy": return "snow"
        case "Thunderstorm": return "cloud.bolt.fill"
        default: return isNight ? "cloud.moon.fill" : "cloud.sun.fill"
        }
    }
}

struct CityTextView: View {
    var cityName: String
    var body: some View {
        Text(cityName)
            .font(.system(size: 32, weight: .medium, design: .default))
            .foregroundColor(.white)
            .padding()
    }
}
