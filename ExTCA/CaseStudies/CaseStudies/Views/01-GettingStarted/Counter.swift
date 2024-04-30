//
//  Counter.swift
//  CaseStudies
//
//  Created by 김건우 on 4/30/24.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct Counter {
    
    // MARK: - State
    @ObservableState
    struct State: Equatable {
        var count = 0
    }
    
    // MARK: - Action
    enum Action {
        case decrementButtonTapped
        case incrementButtonTapped
    }
    
    // MARK: - Reducer
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .decrementButtonTapped:
                state.count -= 1
                return .none
                
            case .incrementButtonTapped:
                state.count += 1
                return .none
            }
        }
    }
    
}

struct CounterView: View {
    
    // MARK: - Store
    let store: StoreOf<Counter>
    
    // MARK: - Body
    var body: some View {
        HStack {
            Button {
                store.send(.decrementButtonTapped)
            } label: {
                Image(systemName: "minus")
            }
            
            Text("\(store.count)")
                .monospacedDigit()
            
            Button {
                store.send(.incrementButtonTapped)
            } label: {
                Image(systemName: "plus")
            }
        }
    }
}

struct CounterDemoView: View {
    
    // MARK: - Store
    let store: StoreOf<Counter>
    
    // MARK: - Body
    var body: some View {
        List {
            Section {
                CounterView(store: store)
                    .frame(maxWidth: .infinity)
            }
        }
        .buttonStyle(.borderless)
        .navigationTitle("Counter demo")
    }
    
}

#Preview {
    CounterView(
        store: StoreOf<Counter>(initialState: Counter.State()) {
            Counter()
        }
    )
}
