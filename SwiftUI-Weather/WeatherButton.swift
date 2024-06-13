//
//  WeatherButton.swift
//  SwiftUI-Weather
//
//  Created by Shai-MAC on 07/06/2024.
//

import SwiftUI

struct WeatherButton: View
{
    var title: String
    var textColor: Color
    var backgroundColor: Color
    
    var body: some View
    {
        Text(title)
            .frame(width: 280, height: 50)
            .background(backgroundColor)
            .foregroundColor(textColor)
            .font(.system(size: 20, weight: .bold))
            .cornerRadius(10)
    }
}
