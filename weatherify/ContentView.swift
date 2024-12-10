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
                    BackgroundView(isNight: $isNight)
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

                        Button {
                            isNight.toggle()
                        } label: {
                            WeatherButton(
                                title: "Change Day Time",
                                textColor: .blue,
                                backColor: .white
                            )
                            .frame(width: geometry.size.width * 0.6, height: 50)
                        }

                        Spacer()
                    }
                }
                .onAppear {
                    weatherViewModel.loadCities()
                    weatherViewModel.startLocationUpdates() // Automatically get user's location
                }
            }
        }
}

#Preview {
    ContentView()
}

// MARK: - View Model

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


// MARK: - Extensions

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

struct BackgroundView: View {
    @Binding var isNight: Bool
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [isNight ? .black : .blue, isNight ? .gray : .purple]), startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
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
