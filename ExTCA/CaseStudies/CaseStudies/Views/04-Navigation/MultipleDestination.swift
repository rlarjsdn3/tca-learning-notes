//
//  MultipleDestination.swift
//  CaseStudies
//
//  Created by 김건우 on 5/1/24.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct MultipleDestination {
    
    // MARK: - State
    @ObservableState
    struct State: Equatable {
        @Presents var destination: Destination.State?
    }
    
    // MARK: - Action
    enum Action {
        case destination(PresentationAction<Destination.Action>)
        case showDrillDown
        case showPopover
        case showSheet
    }
    
    // MARK: - Destination
    @Reducer(state: .equatable)
    enum Destination {
        case drillDown(Counter)
        case popover(Counter)
        case sheet(Counter)
    }
    
    // MARK: - Reducer
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .showDrillDown:
                state.destination = .drillDown(Counter.State())
                return .none
                
            case .showPopover:
                state.destination = .popover(Counter.State())
                return .none
                
            case .showSheet:
                state.destination = .sheet(Counter.State())
                return .none
                
            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

struct MultipleDestinationView: View {
    
    // MARK: - Store
    @Bindable var store: StoreOf<MultipleDestination>
    
    // MARK: - Body
    var body: some View {
        List {
            Button("Show drill-down") {
                store.send(.showDrillDown)
            }
            Button("Show popover") {
                store.send(.showPopover)
            }
            Button("Show sheet") {
                store.send(.showSheet)
            }
        }
        .navigationDestination(
            item: $store.scope(state: \.destination?.drillDown, action: \.destination.drillDown)
        ) { store in
                CounterView(store: store)
        }
        .popover(
            item: $store.scope(state: \.destination?.popover, action: \.destination.popover))
        { store in
            CounterView(store: store)
        }
        .sheet(
            item: $store.scope(state: \.destination?.sheet, action: \.destination.sheet)
        ) { store in
            CounterView(store: store)
        }
    }
}

#Preview {
    MultipleDestinationView(
        store: StoreOf<MultipleDestination>(initialState: MultipleDestination.State()) {
            MultipleDestination()
        }
    )
}
