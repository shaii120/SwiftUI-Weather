//
//  ContentView.swift
//  SwiftUI-Weather
//
//  Created by Shai-MAC on 03/06/2024.
//

import SwiftUI

struct ContentView: View
{
    @State private var isNight = false
    @State var current: WeatherData?
    @State var daily: [WeatherData]?
    
    var body: some View
    {
        ZStack
        {
            BackgroundColorView(isNight: isNight)
            
            VStack
            {
                CityTextView(cityName: "Tel-Aviv, ISR")
                TodayWeatherView(imageName: isNight ? "moon.stars.fill" : "cloud.sun.fill",
                                 temperature: current?.temperature ?? 32
                )
                
                HStack(spacing: 15)
                {
                    ForEach(daily ?? [WeatherData]())
                    {
                        DailyWeatherView(dayOfWeek: $0.day, imageName: $0.daySymbol, temperature: $0.temperature)
                    }
                }
                Spacer()
                
                Button
                {
                    isNight.toggle()
                } label:
                {
                    WeatherButton(title: "Change Day Time Mode",
                                  textColor: .blue,
                                  backgroundColor: .white)
                }
                
                Spacer()
            }
        }
        .task
        {
            do
            {
                try await getWeatherData()
                { (current, daily) in
                    self.current = current
                    self.daily = daily
                }
            }
            catch let error
            {
                debugPrint(error)
            }
        }
    }
}

struct DailyWeatherView : View
{
    var dayOfWeek: String
    var imageName: String
    var temperature: Double
    
    var body: some View
    {
        VStack
        {
            Text(dayOfWeek)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white)
            Image(systemName: imageName)
                .symbolRenderingMode(.multicolor)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
            Text("\(temperature, specifier: "%.1f")°")
                .font(.system(size: 25, weight: .medium))
                .foregroundColor(.white)
        }
    }
}

struct ContentView_Previews: PreviewProvider
{
    static var previews: some View
    {
        ContentView()
    }
}

struct BackgroundColorView: View
{
    var isNight: Bool
    
    var body: some View
    {
        LinearGradient(gradient: Gradient(colors: [isNight ? .black : .blue,
                                                   isNight ? Color("darkBlue") : Color("lightYellow")]),
                       startPoint: .topLeading,
                       endPoint: .bottomTrailing)
            .ignoresSafeArea()
    }
}

struct CityTextView: View
{
    var cityName: String
    
    var body: some View
    {
        Text(cityName)
        .font(.system(size: 32, weight: .medium))
            .foregroundColor(.white)
            .padding()
    }
}

struct TodayWeatherView: View
{
    var imageName: String
    var temperature: Double
    
    var body: some View
    {
        VStack(spacing: 10)
        {
            Image(systemName: imageName)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 180, height: 180)
            Text("\(temperature, specifier: "%.1f")°")
                .font(.system(size: 70, weight: .medium))
                .foregroundColor(.white)
        }
        .padding(.bottom, 60)
    }
}
