//
//  ContentView.swift
//  WeatherSearch
//
//  Created by 김건우 on 4/25/24.
//

import ComposableArchitecture
import SwiftUI

struct WeatherSearchView: View {
    
    // MARK: - Store
    @Bindable var store: StoreOf<WeatherSearch>
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "magnifyingglass")
                    TextField(
                        "New York, San Francisco, ...", text: $store.searchQuery.sending(\.searchQueryChanged)
                    )
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                }
                .padding(.horizontal, 16)
                
                List {
                    ForEach(store.results) { location in
                        VStack(alignment: .leading) {
                            Button {
                                store.send(.searchResultTapped(location))
                            } label: {
                                HStack {
                                    Text(location.name)
                                    
                                    if store.resultForcastRequestInFlight?.id == location.id {
                                        ProgressView()
                                    }
                                }
                            }
                            
                            if location.id == store.weather?.id {
                                weatherView(locationWeather: store.weather)
                            }
                        }
                    }
                }
                
                Button("Weather API provided by Open-Meteo") {
                    UIApplication.shared.open(URL(string: "https://open-meteo.com/en")!)
                }
                .foregroundColor(.gray)
                .padding(.all, 16)
            }
            .navigationTitle("Search")
        }
        .task(id: store.searchQuery) {
            do {
                try await Task.sleep(for: .milliseconds(300))
                await store.send(.searchQueryChangeDebounced).finish()
            } catch { }
        }
    }
    
    @ViewBuilder
    func weatherView(locationWeather: WeatherSearch.State.Weather?) -> some View {
        if let locationWeather {
            let days = locationWeather.days
                .enumerated()
                .map { idx, weather in formattedWeather(day: weather, isToday: idx == 0) }
            
            VStack(alignment: .leading) {
                ForEach(days, id: \.self) { day in
                    Text(day)
                }
            }
            .padding(.leading, 16)
        }
    }
}

private func formattedWeather(day: WeatherSearch.State.Weather.Day, isToday: Bool) -> String {
    let date =
    isToday
    ? "Today"
    : dateFormatter.string(from: day.date).capitalized
    let min = "\(day.temperatureMin)\(day.temperatureMinUnit)"
    let max = "\(day.temperatureMax)\(day.temperatureMaxUnit)"
    
    return "\(date), \(min) – \(max)"
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE"
    return formatter
}()

// MARK: - Preview
#Preview {
    WeatherSearchView(
        store: .init(initialState: WeatherSearch.State()) {
            WeatherSearch()
        }
    )
}
