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
    @Published var availableCities: [City] = []
    @Published var filteredCities: [City] = []
    @Published var forecast: [WeatherDay] = []

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

            self?.weatherService.fetchWeather(for: coordinates) { weather in
                DispatchQueue.main.async {
                    self?.weather = weather
                }
            }

            self?.weatherService.fetchFiveDayForecast(for: coordinates) { forecast in
                DispatchQueue.main.async {
                    self?.forecast = forecast ?? []
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

        // Stop updating to conserve battery once the location is fetched
        locationManager?.stopUpdatingLocation()

        // Fetch city and weather based on location
        fetchCityForLocation(coordinate: location.coordinate)
    }

    @objc func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error.localizedDescription)")
    }

    func fetchCityForLocation(coordinate: CLLocationCoordinate2D?) {
        guard let coordinate = coordinate else { return }

        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            if let error = error {
                print("Error reverse geocoding: \(error)")
                return
            }

            if let placemark = placemarks?.first {
                self?.cityName = placemark.locality ?? "Unknown"
                self?.fetchWeather()
            }
        }
    }
}
