//
//  WeatherForecastTests.swift
//  WeatherForecastTests
//
//  Created by David Jangdal on 2023-04-04.
//

import XCTest
import CoreLocation
@testable import WeatherForecast

final class WeatherForecastTests: XCTestCase {
    func testViewModel_parsingCorrectData() async throws {
        let viewModel = ForecastListViewModel(weatherFetcher: MockedWeatherFetcher(), cities: [City(name: "City", coordinate: .init())])
        await viewModel.fetchForecasts()
        let forecasts = viewModel.forecasts
        XCTAssertEqual(forecasts.first?.cityName, "City")
        XCTAssertEqual(forecasts.first?.symbolName, "symbol name 1")
        XCTAssertEqual(forecasts.first?.details[0].name, "Time")
        XCTAssertEqual(forecasts.first?.details[1].name, "Wind")
        XCTAssertEqual(forecasts.first?.details[2].name, "Humidity")
        XCTAssertEqual(forecasts.first?.details[3].name, "Temperature")
        XCTAssertEqual(forecasts.first?.details[1].value, "600.0")
        XCTAssertEqual(forecasts.first?.details[2].value, "400.0")
        XCTAssertEqual(forecasts.first?.details[3].value, "200.0")
    }

    // Could add following tests
    // Add test when timeseries is missing
    // Add test when symbol of timeseries is missing

}

private final class MockedWeatherFetcher: WeatherFetcherProtocol {
    func fetchWeather(for coordinate: CLLocationCoordinate2D) async throws -> WeatherForecast.WeatherForecastResponse {
        WeatherForecastResponse(
            properties: .init(
                meta: .init(updated_at: .now,
                            units: .init(air_pressure_at_sea_level: "hPa",
                                         air_temperature: "celsius",
                                         cloud_area_fraction: "%",
                                         precipitation_amount: "mm",
                                         relative_humidity: "%",
                                         wind_from_direction: "degrees",
                                         wind_speed: "hPa")),
                timeseries: [.init(time: .now,
                                   data: .init(instant: .init(details: .init(air_pressure_at_sea_level: 100,
                                                                             air_temperature: 200,
                                                                             cloud_area_fraction: 300,
                                                                             relative_humidity: 400,
                                                                             wind_from_direction: 500,
                                                                             wind_speed: 600)),
                                               next_12_hours: .init(summary: .init(symbol_code: "Symbol name 12"),
                                                                    details: .init(precipitation_amount: 12)),
                                               next_1_hours: .init(summary: .init(symbol_code: "symbol name 1"),
                                                                   details: .init(precipitation_amount: 1)),
                                               next_6_hours: .init(summary: .init(symbol_code: "symbol name 6"),
                                                                   details: .init(precipitation_amount: 6))))]))
    }
}
