//
//  WeatherForecastApp.swift
//  WeatherForecast
//
//  Created by David Jangdal on 2023-04-04.
//

import SwiftUI
import CoreLocation
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
        let cities = [City(name: "Gothenburg",
                       coordinate: CLLocationCoordinate2D(latitude: 57.708870, longitude: 11.974560)),
                  City(name: "Mountain View",
                       coordinate: CLLocationCoordinate2D(latitude: 37.386051, longitude: -122.083855)),
                  City(name: "London",
                       coordinate: CLLocationCoordinate2D(latitude: 51.503399, longitude: -0.119519)),
                  City(name: "New York",
                       coordinate: CLLocationCoordinate2D(latitude: 40.712772, longitude: -74.006058)),
                  City(name: "Berlin",
                       coordinate: CLLocationCoordinate2D(latitude: 52.520008, longitude: 13.404954))]
        forecastListViewModel = ForecastListViewModel(weatherFetcher: weatherFetcher, cities: cities)
    }

    var body: some Scene {
        WindowGroup {
            ForecastListView(viewModel: forecastListViewModel)
        }
    }
}
