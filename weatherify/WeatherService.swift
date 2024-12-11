//
//  WeatherService.swift
//  weatherify
//
//  Created by Phoenix Pereira on 8/12/2024.
//

import Foundation

class WeatherService {
    func fetchCoordinates(for city: String, completion: @escaping ((Double, Double)?) -> Void) {
        let urlString = "https://geocoding-api.open-meteo.com/v1/search?name=\(city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL for city: \(city)")
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching coordinates: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("No data received for geocoding.")
                completion(nil)
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(GeocodingResponse.self, from: data)
                if let result = decodedResponse.results.first {
                    completion((result.latitude, result.longitude))
                } else {
                    completion(nil)
                }
            } catch {
                print("Error decoding geocoding response: \(error.localizedDescription)")
                completion(nil)
            }
        }.resume()
    }

    func fetchWeather(for coordinates: (Double, Double), completion: @escaping (Weather?) -> Void) {
        let (lat, lon) = coordinates
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(lat)&longitude=\(lon)&current_weather=true"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL for weather API")
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching weather: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("No data received for weather.")
                completion(nil)
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(OpenMeteoResponse.self, from: data)
                let weather = Weather(
                    temperature: decodedResponse.current_weather.temperature,
                    condition: self.mapCondition(decodedResponse.current_weather.weathercode)
                )
                completion(weather)
            } catch {
                print("Error decoding weather response: \(error.localizedDescription)")
                completion(nil)
            }
        }.resume()
    }
    
    private func mapCondition(_ weatherCode: Int) -> String {
        switch weatherCode {
        case 0: return "Clear sky"
        case 1, 2, 3: return "Partly cloudy"
        case 45, 48: return "Foggy"
        case 51, 53, 55: return "Drizzle"
        case 61, 63, 65: return "Rainy"
        case 71, 73, 75: return "Snowy"
        case 80, 81, 82: return "Rain showers"
        case 95, 96, 99: return "Thunderstorm"
        default: return "Unknown"
        }
    }
    
    func fetchFiveDayForecast(for coordinates: (Double, Double), completion: @escaping ([WeatherDay]?) -> Void) {
        let (lat, lon) = coordinates
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(lat)&longitude=\(lon)&daily=temperature_2m_max,temperature_2m_min,weathercode&timezone=auto"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL for weather API")
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching forecast: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("No data received for forecast.")
                completion(nil)
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(DailyForecastResponse.self, from: data)
                let weatherDays = zip(decodedResponse.daily.time, decodedResponse.daily.weathercode).enumerated().map { index, element in
                    let (date, code) = element
                    return WeatherDay(
                        dayOfWeek: self.dayOfWeek(from: date),
                        weatherCode: code,
                        maxTemperature: decodedResponse.daily.temperature_2m_max[index],
                        minTemperature: decodedResponse.daily.temperature_2m_min[index]
                    )
                }
                completion(weatherDays)
            } catch {
                print("Error decoding forecast response: \(error.localizedDescription)")
                completion(nil)
            }
        }.resume()
    }

    private func dayOfWeek(from date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let date = dateFormatter.date(from: date) else { return "Unknown" }
        dateFormatter.dateFormat = "EEE"
        return dateFormatter.string(from: date).uppercased()
    }
}

// Models for decoding the GeoNames response
struct GeoNamesResponse: Codable {
    let geonames: [GeoName]
}

struct GeoName: Codable {
    let name: String
    let fcl: String
    let fcode: String
}
