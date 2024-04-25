//
//  WeatherSearch.swift
//  WeatherSearch
//
//  Created by 김건우 on 4/25/24.
//

import ComposableArchitecture
import Foundation

@Reducer
struct WeatherSearch {
    
    // MARK: - State
    @ObservableState
    struct State: Equatable {
        var results: [GeocodingSearch.Result] = []
        var resultForcastRequestInFlight: GeocodingSearch.Result?
        var searchQuery = ""
        var weather: Weather?
        
        struct Weather: Equatable {
            var id: GeocodingSearch.Result.ID
            var days: [Day]
            
            struct Day: Equatable {
                var date: Date
                var temperatureMax: Double
                var temperatureMaxUnit: String
                var temperatureMin: Double
                var temperatureMinUnit: String
            }
        }
    }
    
    // MARK: - Action
    enum Action {
        case forecastResponse(GeocodingSearch.Result.ID, Result<Forecast, Error>)
        case searchQueryChanged(String)
        case searchQueryChangeDebounced
        case searchResponse(Result<GeocodingSearch, Error>)
        case searchResultTapped(GeocodingSearch.Result)
    }
    
    // MARK: - Dependencies
    @Dependency(\.weatherClient) var weatherClient
    
    // MARK: - Id
    private enum CancelID { case location, weather }
    
    // MARK: - Reducer
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .forecastResponse(_, .failure):
                state.weather = nil
                state.resultForcastRequestInFlight = nil
                return .none
                
            case let .forecastResponse(id, .success(forecast)):
                state.weather = State.Weather(
                    id: id,
                    days: forecast.daily.time.indices.map{
                        State.Weather.Day(
                            date: forecast.daily.time[$0],
                            temperatureMax: forecast.daily.temperatureMax[$0],
                            temperatureMaxUnit: forecast.dailyUnits.temperatureMax,
                            temperatureMin: forecast.daily.temperatureMin[$0],
                            temperatureMinUnit: forecast.dailyUnits.temperatureMin
                        )
                    }
                )
                state.resultForcastRequestInFlight = nil
                return .none
                
            case let .searchQueryChanged(query):
                state.searchQuery = query
                
                guard !state.searchQuery.isEmpty else {
                    state.results = []
                    state.weather = nil
                    return .cancel(id: CancelID.location)
                }
                return .none
                
            case .searchQueryChangeDebounced:
                guard !state.searchQuery.isEmpty else {
                    return .none
                }
                return .run { [query = state.searchQuery] send in
                    await send(.searchResponse(Result { try await self.weatherClient.search(query: query) }))
                }
                .cancellable(id: CancelID.location)
                
            case .searchResponse(.failure):
                state.results = []
                return .none
                
            case let .searchResponse(.success(response)):
                state.results = response.results
                return .none
                
            case let .searchResultTapped(location):
                state.resultForcastRequestInFlight = location
                
                return .run { send in
                    await send(
                        .forecastResponse(
                            location.id,
                            Result { try await self.weatherClient.forecast(location: location) }
                        )
                    )
                }
                .cancellable(id: CancelID.weather, cancelInFlight: true)
            }
        }
    }
}
