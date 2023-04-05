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
                    .padding(top: 30)
                    .font(.headline)
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
    @State private var isExpanded: Bool = false

    var body: some View {
        VStack {
            HStack {
                Text(forecast.cityName)
                    .font(.subheadline)

                Spacer()

                forecast.image
                    .resizable()
                    .frame(width: 30, height: 30)
            }
            .padding(horizontal: 20)

            if isExpanded {
                ForEach(forecast.details) { detail in
                    HStack {
                        Text(detail.name)
                        Spacer()
                        Text(detail.value)
                    }
                    .padding(leading: 30, trailing: 20)
                }
            }
        }
        .padding(vertical: 20)
        .background(Color.black.opacity(0.1))
        .cornerRadius(20)
        .padding(horizontal: 20)
        .onTapGesture {
            isExpanded.toggle()
        }
    }
}

struct ForecastListView_Previews: PreviewProvider {
    static var previews: some View {
        ForecastListView(viewModel: MockedViewModel())
    }

    private class MockedViewModel: ForecastListViewModelProtocol {
        var forecasts: [ForecastInfo] = [ForecastInfo(cityName: "Stockholm",
                                                      symbolName: "clearsky_night",
                                                      details: [.init(name: "Temperature", value: "12.0")]),
                                         ForecastInfo(cityName: "New York",
                                                      symbolName: "clearsky_day",
                                                      details: []),
                                         ForecastInfo(cityName: "Luleå",
                                                      symbolName: "fog",
                                                      details: []),
                                         ForecastInfo(cityName: "Brisbane",
                                                      symbolName: "heavyrain",
                                                      details: []),]
        func fetchForecasts() async {}
    }
}

struct ForecastInfo: Identifiable {
    let id = UUID()
    let cityName: String
    let symbolName: String
    let details: [Detail]

    var image: Image {
        guard let image = UIImage(named: symbolName) else {
            return Image(systemName: "xmark")
        }
        return Image(uiImage: image)
    }

    struct Detail: Identifiable {
        let id = UUID()
        let name: String
        let value: String
    }
}
