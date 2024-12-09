//
//  Structs.swift
//  weatherify
//
//  Created by Phoenix Pereira on 8/12/2024.
//

import Foundation

struct Weather {
    let temperature: Double
    let condition: String
}

struct OpenMeteoResponse: Codable {
    struct CurrentWeather: Codable {
        let temperature: Double
        let weathercode: Int
    }
    
    let current_weather: CurrentWeather
}

struct GeocodingResponse: Codable {
    struct Result: Codable {
        let name: String
        let latitude: Double
        let longitude: Double
    }
    
    let results: [Result]
}

struct DailyForecastResponse: Codable {
    struct Daily: Codable {
        let time: [String]
        let temperature_2m_max: [Double]
        let temperature_2m_min: [Double]
        let weathercode: [Int]
    }
    
    let daily: Daily
}

struct WeatherDay {
    let dayOfWeek: String
    let weatherCode: Int
    let maxTemperature: Double
    let minTemperature: Double
    
    func conditionImageName() -> String {
        switch weatherCode {
        case 0: return "sun.max.fill"
        case 1, 2, 3: return "cloud.sun.fill"
        case 45, 48: return "cloud.fog.fill"
        case 51, 53, 55: return "cloud.drizzle.fill"
        case 61, 63, 65: return "cloud.rain.fill"
        case 71, 73, 75: return "cloud.snow.fill"
        case 80, 81, 82: return "cloud.heavyrain.fill"
        case 95, 96, 99: return "cloud.bolt.fill"
        default: return "questionmark"
        }
    }
}

struct City: Identifiable {
    let id: String
    let name: String
    let iso2: String
}


