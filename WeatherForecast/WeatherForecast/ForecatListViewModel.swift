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
    private let weatherFetcher: WeatherFetcherProtocol

    @Published var forecasts: [ForecastInfo] = []

    private let cities: [City]

    init(weatherFetcher: WeatherFetcherProtocol, cities: [City]) {
        self.weatherFetcher = weatherFetcher
        self.cities = cities
    }


    @MainActor func fetchForecasts() async {
        do {
            forecasts = try await cities.concurrentMap { [weak weatherFetcher] city in
                let response = try await weatherFetcher?.fetchWeather(for: city.coordinate)
                guard let timeSerie = response?.properties.timeseries.first else {
                        return ForecastInfo(cityName: city.name, symbolName: "cross", details: [])
                }
                guard let symbolName = timeSerie.data.next_1_hours?.summary.symbol_code else {
                    return ForecastInfo(cityName: city.name, symbolName: "cross", details: [])
                }

                return ForecastInfo(cityName: city.name,
                                    symbolName: symbolName,
                                    details: [.init(name: "Time", value: timeSerie.time.formatted()),
                                              .init(name: "Wind", value: "\(timeSerie.data.instant.details.wind_speed)"),
                                              .init(name: "Humidity", value: "\(timeSerie.data.instant.details.relative_humidity)"),
                                              .init(name: "Temperature", value: "\(timeSerie.data.instant.details.air_temperature)")])
            }
        } catch {
            print("Could not refresh forecasts: \(error)")
        }
    }
}

struct City: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}

private extension Sequence {
    func asyncMap<T>(_ transform: (Element) async throws -> T) async rethrows -> [T] {
        var values = [T]()

        for element in self {
            try await values.append(transform(element))
        }

        return values
    }
}

private extension Sequence {
    func concurrentMap<T>(_ transform: @escaping (Element) async throws -> T) async throws -> [T] {
        let tasks = map { element in
            Task {
                try await transform(element)
            }
        }

        return try await tasks.asyncMap { task in
            try await task.value
        }
    }
}
