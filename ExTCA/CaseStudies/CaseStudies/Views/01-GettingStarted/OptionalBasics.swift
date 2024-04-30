//
//  OptionalBasics.swift
//  CaseStudies
//
//  Created by 김건우 on 4/30/24.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct OptionalBasics {
    
    // MARK: - Basics
    @ObservableState
    struct State: Equatable {
        var optionalCounter: Counter.State?
    }
    
    // MARK: - Action
    enum Action {
        case optionalCounter(Counter.Action)
        case toggleCounterButtonTapped
    }
    
    // MARK: - Reducer
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .toggleCounterButtonTapped:
                state.optionalCounter =
                state.optionalCounter == nil
                ? Counter.State()
                : nil
                return .none
                
            case .optionalCounter:
                return .none
            }
        }
        .ifLet(\.optionalCounter, action: \.optionalCounter) {
            Counter()
        }
    }
    
}

struct OptionalBasicsView: View {
    
    // MARK: - Store
    let store: StoreOf<OptionalBasics>
    
    // MARK: - Body
    var body: some View {
        List {
            Button("Toggle counter state") {
                store.send(
                    .toggleCounterButtonTapped,
                    animation: .interactiveSpring
                )
            }
            
            if let store = store.scope(state: \.optionalCounter, action: \.optionalCounter) {
                Text("`Counter.State` is non-`nil`")
                CounterView(store: store)
                    .buttonStyle(.borderless)
                    .frame(maxWidth: .infinity)
            } else {
                Text("`Counter.State` is `nil`")
            }
        }
        .navigationTitle("Optional state")
    }
}

#Preview {
    OptionalBasicsView(
        store: StoreOf<OptionalBasics>(initialState: OptionalBasics.State()) {
            OptionalBasics()
        }
    )
}
