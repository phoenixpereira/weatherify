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
            ZStack {
                BackgroundView(weatherCondition: weatherViewModel.weather?.condition ?? "Clear sky", isNight: $isNight)
                VStack {
                    // Search Bar
                    TextField("Search City", text: $searchQuery)
                        .padding()
                        .frame(width: geometry.size.width * 0.9, height: 50)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .onChange(of: searchQuery) { newQuery in
                            weatherViewModel.filterCities(query: newQuery)
                        }

                    // City Suggestions List
                    if !searchQuery.isEmpty {
                        VStack(alignment: .leading, spacing: 0) {
                            List(weatherViewModel.filteredCities, id: \.id) { city in
                                Text(city.name)
                                    .onTapGesture {
                                        weatherViewModel.cityName = city.name
                                        weatherViewModel.fetchWeather()
                                        searchQuery = ""  // Clear the search query
                                    }
                            }
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(10)
                            .frame(width: geometry.size.width * 0.9, height: 250)
                        }
                    }

                    CityTextView(cityName: weatherViewModel.cityName)

                    // Weather status view
                    if let weather = weatherViewModel.weather {
                        WeatherStatusView(
                            imageName: weather.conditionImageName(isNight: isNight),
                            temperature: Int(weather.temperature),
                            geometry: geometry
                        )
                    } else {
                        Text("Loading weather...")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(.white)
                    }

                    // Forecast view
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 1) {
                            ForEach(weatherViewModel.forecast, id: \.dayOfWeek) { weatherDay in
                                WeatherDayView(
                                    dayOfWeek: weatherDay.dayOfWeek,
                                    imageName: weatherDay.conditionImageName(),
                                    temperature: Int(weatherDay.maxTemperature)
                                )
                                .frame(width: geometry.size.width * 0.2)
                            }
                        }
                    }
                    .padding(.vertical)

                    Spacer()
                }
            }
            .onAppear {
                weatherViewModel.loadCities()
                weatherViewModel.startLocationUpdates() // Automatically get user's location
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

struct WeatherDayView: View {
    var dayOfWeek: String
    var imageName: String
    var temperature: Int
    
    var body: some View {
        VStack{
            Text(dayOfWeek)
                .font(.system(size: 16, weight: .medium, design: .default))
                .foregroundStyle(.white)
            Image(systemName: imageName)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
            Text("\(temperature)°")
                .font(.system(size: 28, weight: .medium))
                .foregroundStyle(.white)
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

struct WeatherStatusView: View {
    var imageName: String
    var temperature: Int
    var geometry: GeometryProxy

    var body: some View {
        VStack {
            Image(systemName: imageName)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: geometry.size.width * 0.5, height: geometry.size.width * 0.5)
            Text("\(temperature)°")
                .font(.system(size: geometry.size.width * 0.2, weight: .medium))
                .foregroundColor(.white)
        }
        .padding(.bottom, geometry.size.height * 0.05)
    }
}
