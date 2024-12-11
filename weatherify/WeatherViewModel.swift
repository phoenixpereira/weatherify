//
//  WeatherViewModel.swift
//  weatherify
//
//  Created by Phoenix Pereira on 10/12/2024.
//

import SwiftUI
import CoreLocation
import CoreLocationUI

class WeatherViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var weather: Weather?
    @Published var cityName: String = "Adelaide" // Default city
    @Published var cityTimezone: String? // To hold the timezone of the city
    @Published var availableCities: [City] = []
    @Published var filteredCities: [City] = []
    @Published var forecast: [WeatherDay] = []
    @Published var hourlyForecast: [HourlyWeather] = []

    private let weatherService = WeatherService()
    private var allCities: [City] = []
    private let cityService = CityService()

    private var locationManager: CLLocationManager?

    override init() {
        super.init()
        loadCities()
    }

    func loadCities() {
        allCities = cityService.loadCities()
        filteredCities = allCities
    }

    func filterCities(query: String) {
        if query.isEmpty {
            filteredCities = allCities
        } else {
            filteredCities = allCities.filter { $0.name.lowercased().contains(query.lowercased()) }
        }
    }

    func fetchWeather() {
        weatherService.fetchCoordinates(for: cityName) { [weak self] coordinates in
            guard let coordinates = coordinates else {
                print("Failed to fetch coordinates.")
                return
            }

            self?.weatherService.fetchDailyWeather(for: coordinates) { weather in
                DispatchQueue.main.async {
                    self?.weather = weather
                }
            }

            self?.weatherService.fetchWeeklyForecast(for: coordinates) { forecast in
                DispatchQueue.main.async {
                    self?.forecast = forecast ?? []
                }
            }
            
            self?.weatherService.fetchHourlyWeather(for: coordinates) { hourlyForecast in
                DispatchQueue.main.async {
                    self?.hourlyForecast = hourlyForecast ?? []
                }
            }

            self?.fetchTimezone(for: coordinates)
        }
    }

    private func fetchTimezone(for coordinates: (Double, Double)) {
        let location = CLLocation(latitude: coordinates.0, longitude: coordinates.1)
        let geocoder = CLGeocoder()

        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            if let error = error {
                print("Error fetching timezone: \(error)")
                return
            }

            if let placemark = placemarks?.first {
                DispatchQueue.main.async {
                    self?.cityTimezone = placemark.timeZone?.identifier
                }
            }
        }
    }

    func startLocationUpdates() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.startUpdatingLocation()
    }

    @objc func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }

        locationManager?.stopUpdatingLocation()
        fetchCityForLocation(coordinate: (location.coordinate.latitude, location.coordinate.longitude))
    }

    @objc func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error.localizedDescription)")
    }

    func fetchCityForLocation(coordinate: (Double, Double)) {
        let location = CLLocation(latitude: coordinate.0, longitude: coordinate.1)
        let geocoder = CLGeocoder()

        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            if let error = error {
                print("Error reverse geocoding: \(error)")
                return
            }

            if let placemark = placemarks?.first {
                DispatchQueue.main.async {
                    self?.cityName = placemark.locality ?? "Unknown"
                    self?.cityTimezone = placemark.timeZone?.identifier
                    self?.fetchWeather()
                }
            }
        }
    }
}
