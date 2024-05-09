//
//  Refrashable.swift
//  CaseStudies
//
//  Created by 김건우 on 5/9/24.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct Refreshable {
    
    // MARK: - State
    @ObservableState
    struct State: Equatable {
        var count = 0
        var fact: String?
    }
    
    // MARK: - Action
    enum Action {
        case cancelButtonTapped
        case decrementButtonTapped
        case incrementButtonTapped
        case factResponse(Result<String, Error>)
        case refresh
    }
    
    // MARK: - Dependencies
    @Dependency(\.factClient) var factClient
    
    // MARK: - Id
    private enum CancelId { case factRequest }
    
    // MARK: - Reducer
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .cancelButtonTapped:
                return .cancel(id: CancelId.factRequest)
                
            case .decrementButtonTapped:
                state.count -= 1
                return .none
                
            case .incrementButtonTapped:
                state.count += 1
                return .none
                
            case let .factResponse(.success(fact)):
                state.fact = fact
                return .none
                
            case .factResponse(.failure):
                // TODO: - Emit an Error
                return .none
                
            case .refresh:
                state.fact = nil
                return .run { [count = state.count] send in
                    await send(
                        .factResponse(Result { try await self.factClient.fetch(count) }),
                        animation: .default
                    )
                }
                .cancellable(id: CancelId.factRequest)
            }
        }
    }
}


struct RefreshableView: View {
    
    // MARK: - Store
    let store: StoreOf<Refreshable>
    @State var isLoading = false
    
    // MARK: - Body
    var body: some View {
        List {
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
            .frame(maxWidth: .infinity)
            .buttonStyle(.borderless)
            
            if let fact = store.fact {
                Text(fact)
                    .bold()
            }
            if self.isLoading {
                Button("Cancel") {
                    store.send(.cancelButtonTapped, animation: .default)
                }
            }
        }
        .refreshable {
            isLoading = true
            defer { isLoading = false }
            await store.send(.refresh).finish()
        }
    }
}

#Preview {
    RefreshableView(
        store: StoreOf<Refreshable>(initialState: Refreshable.State()) {
            Refreshable()
        }
    )
}
