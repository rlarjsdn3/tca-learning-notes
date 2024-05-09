//
//  LoadThenPresent.swift
//  CaseStudies
//
//  Created by 김건우 on 5/6/24.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct LoadThenPresent {
    
    // MARK: - State
    @ObservableState
    struct State: Equatable {
        @Presents var counter: Counter.State?
        var isActivityIndicatorVisible = false
    }
    
    // MARK: - Action
    enum Action {
        case counter(PresentationAction<Counter.Action>)
        case counterButtonTapped
        case counterPresentationDelayCompleted
    }
    
    // MARK: - Dependencies
    @Dependency(\.continuousClock) var clock
    
    // MARK: - Reducer
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .counter:
                return .none
                
            case .counterButtonTapped:
                state.isActivityIndicatorVisible = true
                return .run { send in
                    try await self.clock.sleep(for: .seconds(1))
                    await send(.counterPresentationDelayCompleted)
                }
                
            case .counterPresentationDelayCompleted:
                state.isActivityIndicatorVisible = false
                state.counter = Counter.State()
                return .none
            }
        }
        .ifLet(\.$counter, action: \.counter) {
            Counter()
        }
    }
}

struct LoadThenPresentView: View {
    
    // MARK: - Store
    @Bindable var store: StoreOf<LoadThenPresent>
    
    // MARK: - Body
    var body: some View {
        List {
            Button {
                store.send(.counterButtonTapped)
            } label: {
                Text("Load optional counter")
                if store.isActivityIndicatorVisible {
                    Spacer()
                    ProgressView()
                }
            }
        }
        .sheet(item: $store.scope(state: \.counter, action: \.counter)) { store in
            CounterView(store: store)
        }
        .navigationTitle("Load and present")
    }
}

#Preview {
    LoadThenPresentView(
        store: StoreOf<LoadThenPresent>(initialState: LoadThenPresent.State()) {
            LoadThenPresent()
        }
    )
}
