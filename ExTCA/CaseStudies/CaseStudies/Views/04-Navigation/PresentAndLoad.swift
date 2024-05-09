//
//  PresentAndLoad.swift
//  CaseStudies
//
//  Created by 김건우 on 5/6/24.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct PresentAndLoad {
    
    // MARK: - State
    @ObservableState
    struct State {
        var optionalCounter: Counter.State?
        var isSheetPresented = false
    }
    
    // MARK: - Action
    enum Action {
        case optionalCounter(Counter.Action)
        case setSheet(isPresented: Bool)
        case setSheetIsPresentedDelayCompletd
    }
    
    // MARK: - Dependency
    @Dependency(\.continuousClock) var clock
    
    // MARK: - Id
    private enum CancelID { case load }
    
    // MARK: - Reducer
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .setSheet(isPresented: true):
                state.isSheetPresented = true
                return .run { send in
                    try await self.clock.sleep(for: .seconds(1))
                    await send(.setSheetIsPresentedDelayCompletd)
                }
                .cancellable(id: CancelID.load)
                
            case .setSheet(isPresented: false):
                state.isSheetPresented = false
                state.optionalCounter = nil
                return .cancel(id: CancelID.load)
                
            case .setSheetIsPresentedDelayCompletd:
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

struct PresentAndLoadView: View {
    
    // MARK: - Store
    @Bindable var store: StoreOf<PresentAndLoad>
    
    // MARK:  - Body
    var body: some View {
        List {
            Button("Load optional counter") {
                store.send(.setSheet(isPresented: true))
            }
        }
        .sheet(isPresented: $store.isSheetPresented.sending(\.setSheet)) {
            if let store = store.scope(state: \.optionalCounter, action: \.optionalCounter) {
                CounterView(store: store)
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Present and load")
    }
}

#Preview {
    PresentAndLoadView(
        store: StoreOf<PresentAndLoad>(initialState: PresentAndLoad.State()) {
            
        }
    )
}
