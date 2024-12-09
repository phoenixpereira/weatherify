//
//  CityService.swift
//  weatherify
//
//  Created by Phoenix Pereira on 9/12/2024.
//

import Foundation

class CityService {
    
    func loadCities() -> [City] {
        guard let path = Bundle.main.path(forResource: "cities", ofType: "csv") else {
            print("CSV file not found.")
            return []
        }
        
        do {
            let data = try String(contentsOfFile: path)
                        
            let normalizedData = data.replacingOccurrences(of: "\r\n", with: "\n").replacingOccurrences(of: "\r", with: "\n")
                        
            let rows = normalizedData.split(separator: "\n")
            var cities: [City] = []
            
            for row in rows.dropFirst() { // Skip header row
                let columns = row.split(separator: ",")

                let city = City(
                    id: String(columns[2]),
                    name: String(columns[0]).trimmingCharacters(in: .quotes),
                    iso2: String(columns[1]).trimmingCharacters(in: .quotes)
                )
                cities.append(city)
            }
            print(cities)
            return cities
        } catch {
            print("Failed to read CSV file: \(error.localizedDescription)")
            return []
        }
    }
}

extension CharacterSet {
    static let quotes = CharacterSet(charactersIn: "\"")
}
