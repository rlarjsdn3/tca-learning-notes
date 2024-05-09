//
//  NavigateAndLoadList.swift
//  CaseStudies
//
//  Created by 김건우 on 5/2/24.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct NavigateAndLoadList {
    
    // MARK: - State
    struct State: Equatable {
        var rows: IdentifiedArrayOf<Row> = [
            Row(count: 1, id: UUID()),
            Row(count: 42, id: UUID()),
            Row(count: 100, id: UUID()),
        ]
        var selection: Identified<Row.ID, Counter.State?>?
        
        struct Row: Equatable, Identifiable {
            var count: Int
            let id: UUID
        }
    }
    
    // MARK: - Action
    enum Action {
        case counter(Counter.Action)
        case setNavigation(selection: UUID?)
        case setNavigationSelectionDelayCompleted
    }
    
    // MARK: - Dependencies
    @Dependency(\.continuousClock) var clock
    
    // MARK: - Id
    private enum CancelID { case load }
    
    // MARK: - Reducer
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .counter:
                return .none
                
            case let .setNavigation(selection: .some(id)):
                state.selection = Identified(nil, id: id)
                return .run { send in
                    try await self.clock.sleep(for: .seconds(1))
                    await send(.setNavigationSelectionDelayCompleted)
                }
                .cancellable(id: CancelID.load, cancelInFlight: true)
                
            case .setNavigation(selection: .none):
                if let selection = state.selection, let count = selection.value?.count {
                    state.rows[id: selection.id]?.count = count
                }
                state.selection = nil
                return .cancel(id: CancelID.load)
                
            case .setNavigationSelectionDelayCompleted:
                guard let id = state.selection?.id else { return .none }
                state.selection?.value = Counter.State(count: state.rows[id: id]?.count ?? 0)
                return .none
            }
        }
        .ifLet(\.selection, action: \.counter) {
            EmptyReducer()
                .ifLet(\.value, action: \.self) {
                    Counter()
                }
        }
    }
}

struct NavigateAndLoadListView: View {
    
    // MARK: - Store
    @Bindable var store: StoreOf<NavigateAndLoadList>
    
    // MARK: - Body
    var body: some View {
//        WithViewStore(self.store, observe: { $0 }) { viewStore in
//            List {
//                ForEach(viewStore.rows) { row in
//                    NavigationLink(
//                        "Load optional counter that starts from \(row.count)",
//                        tag: row.id,
//                        selection: viewStore.binding(
//                            get: \.selection?.id,
//                            send: { .setNavigation(selection: $0) }
//                        )
//                    ) {
//                        IfLetStore(self.store.scope(state: \.selection?.value, action: \.counter)) {
//                            CounterView(store: $0)
//                        } else: {
//                            ProgressView()
//                        }
//                    }
//                }
//            }
//            .navigationDestination
//        }
//        .navigationTitle("Navigate and load")
        Text("")
    }
}

#Preview {
    NavigateAndLoadListView(
        store: StoreOf<NavigateAndLoadList>(initialState: NavigateAndLoadList.State()) {
            NavigateAndLoadList()
        }
    )
}
