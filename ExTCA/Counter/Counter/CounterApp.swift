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
    
    // MARK: - Properties
    static let store = Store(initialState: Counter.State()) {
        Counter()
    } withDependencies: { values in
        values.numberFact.fetch = { "\(values) is a good number Brent" }
    }
    
    var body: some Scene {
        WindowGroup {
            CounterView(store: CounterApp.store)
        }
    }
}
