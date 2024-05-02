//
//  NavigateAndLoad.swift
//  CaseStudies
//
//  Created by 김건우 on 5/2/24.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct NavigateAndLoad {
    
    // MARK: - State
    @ObservableState
    struct State: Equatable {
        var isNavigateionActive = false
        var optionalCounter: Counter.State?
    }
    
    // MARK: - Action
    enum Action {
        case optionalCounter(Counter.Action)
        case setNavigation(isActive: Bool)
        case setNavigationIsActiveDelayCompleted
    }
    
    // MARK: - Dependencies
    @Dependency(\.continuousClock) var clock
    
    // MARK: - Id
    private enum CancelID { case load }
    
    // MARK: - Reducer
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .setNavigation(isActive: true):
                state.isNavigateionActive = true
                return .run { send in
                    try await self.clock.sleep(for: .seconds(1))
                    await send(.setNavigationIsActiveDelayCompleted)
                }
                .cancellable(id: CancelID.load)
                
            case .setNavigation(isActive: false):
                state.isNavigateionActive = false
                state.optionalCounter = nil
                return .cancel(id: CancelID.load)
                
            case .setNavigationIsActiveDelayCompleted:
                state.optionalCounter = Counter.State()
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

struct NavigateAndLoadView: View {
    
    // MARK: - Store
    @Bindable var store: StoreOf<NavigateAndLoad>
    
    // MARK: - Body
    var body: some View {
        List {
            NavigationLink(
                "Load optional counter",
                isActive: $store.isNavigateionActive.sending(\.setNavigation)
            ) {
                if let store = store.scope(state: \.optionalCounter, action: \.optionalCounter) {
                    CounterView(store: store)
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Navigate and load")
        }
    }
}

#Preview {
    NavigateAndLoadView(
        store: StoreOf<NavigateAndLoad>(initialState: NavigateAndLoad.State()) {
            NavigateAndLoad()
        }
    )
}
