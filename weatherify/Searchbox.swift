//
//  Searchbox.swift
//  weatherify
//
//  Created by Phoenix Pereira on 11/12/2024.
//


import SwiftUI
import CoreLocation
import CoreLocationUI

struct Searchbox: View {
    @State var searchQuery: String
    var geometry: GeometryProxy
    var weatherViewModel: WeatherViewModel
    
    var body: some View {
        VStack {
            ZStack(alignment: .top) {
                HStack {
                    if !searchQuery.isEmpty {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.black)
                            .padding(.leading, 10)
                    } else {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .padding(.leading, 10)
                    }
                    
                    TextField("Search City", text: $searchQuery)
                        .padding()
                        .frame(height: 50)
                        .foregroundColor(.primary)
                        .onChange(of: searchQuery) { newQuery in
                            weatherViewModel.filterCities(query: newQuery)
                        }
                }
                .frame(width: geometry.size.width * 0.9)
                .background(.thinMaterial)
                .cornerRadius(24)
                
                // Dropdown suggestions
                if !searchQuery.isEmpty {
                    VStack(alignment: .leading, spacing: 0) {
                        List(weatherViewModel.filteredCities, id: \.id) { city in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(city.name)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    Text(city.iso2)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .onTapGesture {
                                    weatherViewModel.cityName = city.name
                                    weatherViewModel.iso2 = city.iso2
                                    weatherViewModel.fetchWeather()
                                    searchQuery = "" // Clear the search query
                                }
                            }
                            .listRowBackground(Color.clear)
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                        .background(.thinMaterial)
                        .cornerRadius(24)
                        .frame(width: geometry.size.width * 0.9, height: 250)
                    }
                    .padding(.top, 60)
                }
                
            }
            .frame(width: geometry.size.width)
            .padding(.top, 10)
        }
    }
}
