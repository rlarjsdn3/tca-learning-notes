//
//  TwoCounters.swift
//  CaseStudies
//
//  Created by 김건우 on 4/30/24.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct TwoCounters {
    
    // MARK: - State
    @ObservableState
    struct State: Equatable {
        var counter1 = Counter.State()
        var counter2 = Counter.State()
    }
    
    // MARK: - Action
    enum Action {
        case counter1(Counter.Action)
        case counter2(Counter.Action)
    }
    
    // MARK: - Reducer
    var body: some ReducerOf<Self> {
        Scope(state: \.counter1, action: \.counter1) {
            Counter()
        }
        Scope(state: \.counter2, action: \.counter2) {
            Counter()
        }
    }
    
}

struct TwoCountersView: View {
    
    // MARK: - Store
    let store: StoreOf<TwoCounters>
    
    // MARK: - Body
    var body: some View {
        List {
            HStack {
                Text("Counter 1")
                Spacer()
                CounterView(store: store.scope(state: \.counter1, action: \.counter1))
            }
            
            HStack {
                Text("Counter 2")
                Spacer()
                CounterView(store: store.scope(state: \.counter2, action: \.counter2))
            }
        }
        .buttonStyle(.borderless)
        .navigationTitle("Two counters demo")
    }
}

#Preview {
    TwoCountersView(
        store: StoreOf<TwoCounters>(initialState: TwoCounters.State()) {
            TwoCounters()
        }
    )
}
