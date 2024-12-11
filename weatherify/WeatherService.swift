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

    func fetchDailyWeather(for coordinates: (Double, Double), completion: @escaping (Weather?) -> Void) {
        let (lat, lon) = coordinates
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(lat)&longitude=\(lon)&current_weather=true&daily=temperature_2m_max,temperature_2m_min"
        
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
                
                let minTemperature = decodedResponse.daily.temperature_2m_min.first ?? 0.0
                let maxTemperature = decodedResponse.daily.temperature_2m_max.first ?? 0.0
                
                let weather = Weather(
                    temperature: Int(decodedResponse.current_weather.temperature),
                    minTemperature: Int(minTemperature),
                    maxTemperature: Int(maxTemperature),
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
    
    func fetchWeeklyForecast(for coordinates: (Double, Double), completion: @escaping ([WeatherDay]?) -> Void) {
        let (lat, lon) = coordinates
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(lat)&longitude=\(lon)&daily=temperature_2m_max,temperature_2m_min,precipitation_probability_max,weathercode&timezone=auto"
        
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
                        minTemperature: decodedResponse.daily.temperature_2m_min[index],
                        precipitationChance: decodedResponse.daily.precipitation_probability_max[index]
                    )
                }
                completion(weatherDays)
            } catch {
                print("Error decoding forecast response: \(error.localizedDescription)")
                completion(nil)
            }
        }.resume()
    }
    
    func fetchHourlyWeather(for coordinates: (Double, Double), completion: @escaping ([HourlyWeather]?) -> Void) {
        let (lat, lon) = coordinates
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(lat)&longitude=\(lon)&hourly=temperature_2m,weathercode,precipitation_probability&timezone=auto"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL for hourly weather API")
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching hourly weather: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("No data received for hourly weather.")
                completion(nil)
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(HourlyForecastResponse.self, from: data)
                
                let hourlyWeather = zip(
                    zip(decodedResponse.hourly.time, decodedResponse.hourly.weathercode),
                    decodedResponse.hourly.precipitation_probability
                )
                .enumerated()
                .prefix(24) // Limit to 24 hours
                .map { index, element in
                    let ((time, code), precipitation) = element
                    return HourlyWeather(
                        time: self.hourOfDay(from: time),
                        weatherCode: code,
                        temperature: decodedResponse.hourly.temperature_2m[index],
                        precipitationChance: precipitation
                    )
                }
                
                completion(hourlyWeather)
            } catch {
                print("Error decoding hourly weather response: \(error.localizedDescription)")
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
    
    private func hourOfDay(from time: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        guard let date = formatter.date(from: time) else { return time }
        formatter.dateFormat = "h a"
        return formatter.string(from: date)
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
