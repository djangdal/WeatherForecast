//
//  WeatherForecastApp.swift
//  WeatherForecast
//
//  Created by David Jangdal on 2023-04-04.
//

import SwiftUI
import CosyNetwork

@main
struct WeatherForecastApp: App {
    private let apiDispatcher: APIDispatcher
    private let weatherFetcher: WeatherFetcher
    private let forecastListViewModel: ForecastListViewModel

    init() {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        apiDispatcher = APIDispatcher(decoder: decoder)
        weatherFetcher = WeatherFetcher(dispatcher: apiDispatcher)
        forecastListViewModel = ForecastListViewModel(weatherFetcher: weatherFetcher)
    }

    var body: some Scene {
        WindowGroup {
            ForecastListView(viewModel: forecastListViewModel)
        }
    }
}
