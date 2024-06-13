//
//  WeatherAPI.swift
//  SwiftUI-Weather
//
//  Created by Shai-MAC on 10/06/2024.
//
import Foundation

func getWeatherFromAPI(completion: @escaping (WeatherDataAPI?) -> ()) async throws
{
    let tlvLatitude = "32.0809"
    let tlvLongitude = "34.7806"
    let endpoint = "https://api.open-meteo.com/v1/forecast"
    var dataWeatherAPI: WeatherDataAPI?
    var components = URLComponents(string: endpoint)!
    components.queryItems = [URLQueryItem(name: "latitude", value:tlvLatitude),
                      URLQueryItem(name: "longitude", value: tlvLongitude),
                      URLQueryItem(name: "current", value: "temperature_2m,precipitation"),
                      URLQueryItem(name: "daily", value: "temperature_2m_max,precipitation_probability_max"),
                      URLQueryItem(name: "forecast_days", value: "5")
    ]
    guard let url = components.url else { throw URLError(.badURL)}
    
    URLSession.shared.dataTask(with: url)
    { data, response, error in
        if let error = error
        {
            fatalError("URL could not be constructed: \(error.localizedDescription)")
        }
        
        if  let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200
        {
            let decoder = JSONDecoder()
//            decoder.keyDecodingStrategy = .convertFromSnakeCase
            do
            {
                dataWeatherAPI = try decoder.decode(WeatherDataAPI.self, from: data!)
                completion(dataWeatherAPI)
            }
            catch
            {
                fatalError("Error decoding data: \(error.localizedDescription)")
            }
        }
    }.resume()
}

func dateToWeekday(dateStr: String) -> String
{
    let dateFormmater = DateFormatter()
    dateFormmater.locale = Locale(identifier: "en_US_POSIX")
    dateFormmater.dateFormat = "yyyy-mm-dd"
    
    let date = dateFormmater.date(from: dateStr)!
    let weekdaySymbols = dateFormmater.shortWeekdaySymbols!
    let weekdayNum = Calendar.current.component(.weekday, from: date)
    return weekdaySymbols[weekdayNum - 1]
}

func selectSymbol(precipitation: Double) -> String
{
    if precipitation < 25 { return "sun.max.fill" }
    if precipitation < 50 { return "cloud.sun.fill" }
    if precipitation < 75 { return "cloud.fill"}
    return "cloud.rain.fill"
}

func parseWeatherData(data: WeatherDataAPI) -> (WeatherData, [WeatherData])
{
    let current: WeatherData = WeatherData(day: dateToWeekday(dateStr: data.daily.time[0]),
                                           temperature: data.current.temperature_2m,
                                           daySymbol: selectSymbol(precipitation: data.current.precipitation))
    let zipped = zip(data.daily.time, zip(data.daily.temperature_2m_max, data.daily.precipitation_probability_max))
    let daily: [WeatherData] = zipped.map { WeatherData(day: dateToWeekday(dateStr: $0), temperature: $1.0, daySymbol: selectSymbol(precipitation: $1.1))}
    
    return (current, daily)
}

func getWeatherData(completion: @escaping ((WeatherData, [WeatherData])) -> Void) async throws
{
    try await getWeatherFromAPI()
    { rawData in
        if let data = rawData
        {
            completion(parseWeatherData(data: data))
        }
    }
}

struct WeatherData: Identifiable
{
    var id: String
    {
        self.day
    }
    let day: String
    let temperature: Double
    let daySymbol: String
}

struct WeatherDataAPI: Decodable
{
    let current: WeatherCurrentDataAPI
    let daily: WeatherDailyDataAPI
}

struct WeatherCurrentDataAPI: Decodable
{
    let precipitation: Double
    let temperature_2m: Double
}

struct WeatherDailyDataAPI: Decodable
{
    let temperature_2m_max: [Double]
    let time: [String]
    let precipitation_probability_max: [Double]
}
