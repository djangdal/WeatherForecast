//
//  ForecastListView.swift
//  WeatherForecast
//
//  Created by David Jangdal on 2023-04-04.
//

import SwiftUI

protocol ForecastListViewModelProtocol: ObservableObject {
    var forecasts: [ForecastInfo] { get }
    @Sendable func fetchForecasts() async
}

struct ForecastListView<ViewModel: ForecastListViewModelProtocol>: View {
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        ScrollView {
            Text("Forecasts")
            VStack {
                ForEach(viewModel.forecasts) { forecast in
                    ForecastListItem(forecast: forecast)
                }
            }
        }
        .refreshable(action: viewModel.fetchForecasts)
        .onAppear{
            Task {
                await viewModel.fetchForecasts()
            }
        }
    }
}

private struct ForecastListItem: View {
    let forecast: ForecastInfo

    var body: some View {
        VStack {
            HStack {
                Text(forecast.cityName)
                    .font(.headline)

                Spacer()

                forecast.image
                    .resizable()
                    .frame(width: 30, height: 30)
            }
            .padding(20)
        }
    }
}

struct ForecastListView_Previews: PreviewProvider {
    static var previews: some View {
        ForecastListView(viewModel: MockedViewModel())
    }

    private class MockedViewModel: ForecastListViewModelProtocol {
        var forecasts: [ForecastInfo] = [ForecastInfo(cityName: "Stockholm",
                                                      symbolName: "clearsky_night"),
                                         ForecastInfo(cityName: "New York",
                                                      symbolName: "clearsky_day"),
                                         ForecastInfo(cityName: "Luleå",
                                                      symbolName: "fog"),
                                         ForecastInfo(cityName: "Brisbane",
                                                      symbolName: "heavyrain")]
        func fetchForecasts() async {}
    }
}

struct ForecastInfo: Identifiable {
    let id = UUID()
    let cityName: String
    let symbolName: String

    var image: Image {
        guard let image = UIImage(named: symbolName) else {
            return Image(systemName: "xmark")
        }
        return Image(uiImage: image)
    }
}
