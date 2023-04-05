//
//  WeatherFetcher.swift
//  WeatherForecast
//
//  Created by David Jangdal on 2023-04-04.
//

import Foundation
import CosyNetwork
import CoreLocation

final class WeatherFetcher {

    private let dispatcher: APIDispatcher

    init(dispatcher: APIDispatcher) {
        self.dispatcher = dispatcher
    }

    func fetchWeather(for coordinate: CLLocationCoordinate2D) async throws -> WeatherForecastResponse {
        let request = WeatherForecastRequest(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let response = try await dispatcher.dispatch(request)
        return response.0
    }
}

fileprivate struct WeatherForecastRequest: APIDecodableRequest {
    typealias ResponseBodyType = WeatherForecastResponse
    typealias ErrorBodyType = WeatherForecastError

    var baseURLPath: String = "https://api.met.no"
    var path: String {
        "/weatherapi/locationforecast/2.0/compact"
    }
    var latitude: Double
    var longitude: Double

    var method: CosyNetwork.HTTPMethod = .get
    var successStatusCodes: [CosyNetwork.HTTPStatusCode] = [.ok]
    var failingStatusCodes: [CosyNetwork.HTTPStatusCode] = [.badRequest]
    var requestHeaders: [String : String]?
    var queryParameters: [String : String]? {
        ["lat": "\(latitude)", "lon": "\(longitude)"]
    }
}

struct WeatherForecastError: Error, Decodable {
}

struct WeatherForecastResponse: Decodable {
    let properties: Properties

    struct Properties: Decodable {
        let meta: Meta
        let timeseries: [ForecastTimeEntry]

        struct Meta: Decodable {
            let updated_at: Date
            let units: Units

            struct Units: Decodable {
                let air_pressure_at_sea_level: String
                let air_temperature: String
                let cloud_area_fraction: String
                let precipitation_amount: String
                let relative_humidity: String
                let wind_from_direction: String
                let wind_speed: String
            }
        }
    }
}


struct ForecastTimeEntry: Decodable {
    let time: Date
    let data: TimeData

    struct TimeData: Decodable {
        let instant: InstantEntry
        let next_12_hours: TimeDataEntry?
        let next_1_hours: TimeDataEntry?
        let next_6_hours: TimeDataEntry?

        struct InstantEntry: Decodable {
            let details: Details

            struct Details: Decodable {
                let air_pressure_at_sea_level: Double
                let air_temperature: Double
                let cloud_area_fraction: Double
                let relative_humidity: Double
                let wind_from_direction: Double
                let wind_speed: Double
            }
        }

        struct TimeDataEntry: Decodable {
            let summary: Summary
            let details: Details?

            struct Summary: Decodable {
                let symbol_code: String
            }

            struct Details: Decodable {
                let precipitation_amount: Double
            }
        }
    }
}
