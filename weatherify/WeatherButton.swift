//
//  WeatherButton.swift
//  weatherify
//
//  Created by Phoenix Pereira on 8/12/2024.
//

import SwiftUI

struct WeatherButton: View {
    var title: String
    var textColor: Color
    var backColor: Color
    var body: some View {
        Text (title)
            .frame(width: 280, height: 50)
            .background(backColor)
            .foregroundStyle(textColor)
            .font(.system(size: 20, weight: .bold, design: .default))
            .cornerRadius (10)
    }
}
