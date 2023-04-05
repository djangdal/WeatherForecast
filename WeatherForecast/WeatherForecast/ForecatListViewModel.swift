//
//  ForecatListViewModel.swift
//  WeatherForecast
//
//  Created by David Jangdal on 2023-04-04.
//

import Foundation
import Combine
import CoreLocation

final class ForecastListViewModel: ForecastListViewModelProtocol {
    private let weatherFetcher: WeatherFetcher

    @Published var forecasts: [ForecastInfo] = []

    private let forecastLocations: [ForecastLocation]

    init(weatherFetcher: WeatherFetcher) {
        self.weatherFetcher = weatherFetcher
        forecastLocations = [ForecastLocation(cityName: "Gothenburg",
                                              coordinate: CLLocationCoordinate2D(latitude: 57.708870, longitude: 11.974560))]
    }


    @MainActor func fetchForecasts() async {
        do {
            let req = forecastLocations.first!
            let response = try await weatherFetcher.fetchWeather(for: forecastLocations.first!.coordinate)
            print("Got response: \(response.properties)")
            forecasts.append(ForecastInfo(cityName: req.cityName, symbolName: response.properties.timeseries.first!.data.next_1_hours?.summary.symbol_code ?? "asd"))
        } catch {
            print("Got error:  \(error)")
        }
    }
}

struct ForecastLocation: Identifiable {
    let id = UUID()
    let cityName: String
    let coordinate: CLLocationCoordinate2D
}
