//
//  WeatherSearchApp.swift
//  WeatherSearch
//
//  Created by 김건우 on 4/25/24.
//

import ComposableArchitecture
import SwiftUI

@main
struct WeatherSearchApp: App {
    
    // MARK: - Store
    static let store = StoreOf<WeatherSearch>(initialState: WeatherSearch.State()) {
        WeatherSearch()
            ._printChanges()
    }
    
    var body: some Scene {
        WindowGroup {
            WeatherSearchView(store: WeatherSearchApp.store)
        }
    }
}
