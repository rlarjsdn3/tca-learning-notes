//
//  CounterApp.swift
//  Counter
//
//  Created by 김건우 on 4/23/24.
//

import ComposableArchitecture
import SwiftUI

@main
struct CounterApp: App {
    
    // MARK: - Store
    static let store = StoreOf<Counter>(initialState: Counter.State()) {
        Counter()
            ._printChanges()
    }
    
    var body: some Scene {
        WindowGroup {
            CounterView(store: CounterApp.store)
        }
    }
}
