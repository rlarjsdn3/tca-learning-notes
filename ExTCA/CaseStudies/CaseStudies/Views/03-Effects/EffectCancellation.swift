//
//  EffectCancellation.swift
//  CaseStudies
//
//  Created by 김건우 on 5/6/24.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct EffectsCancellation {
    
    // MARK: - State
    @ObservableState
    struct State: Equatable {
        var count = 0
        var currentFact: String?
        var isFactRequestInFlight = false
    }
    
    // MARK: - Action
    enum Action {
        case cancelButtonTapped
        case stepperChanged(Int)
        case factButtonTapped
        case factResponse(Result<String, Error>)
    }
    
    // MARK: - Dependencies
    @Dependency(\.factClient) var factClient
    
    // MARK: - Id
    private enum CancelID { case factRequest }
    
    // MARK: - Reducer
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .cancelButtonTapped:
                state.isFactRequestInFlight = false
                return .cancel(id: CancelID.factRequest)
                
            case let .stepperChanged(value):
                state.count = value
                state.currentFact = nil
                state.isFactRequestInFlight = false
                return .cancel(id: CancelID.factRequest)
                
            case .factButtonTapped:
                state.currentFact = nil
                state.isFactRequestInFlight = true
                
                return .run { [count = state.count] send in
                    await send(.factResponse(Result { try await factClient.fetch(count) }))
                }
                .cancellable(id: CancelID.factRequest)
                
            case let .factResponse(.success(response)):
                state.isFactRequestInFlight = false
                state.currentFact = response
                return .none
                
            case .factResponse(.failure):
                state.isFactRequestInFlight = false
                return .none
            }
        }
    }
}

struct EffectsCancellationView: View {
    
    // MARK: - Store
    @Bindable var store: StoreOf<EffectsCancellation>
    
    // MARK: - Environment
    @Environment(\.openURL) var openURL
    
    // MARK: - Body
    var body: some View {
        List {
            Section {
                Stepper("\(store.count)", value: $store.count.sending(\.stepperChanged))
                
                if store.isFactRequestInFlight {
                    HStack {
                        Button("Cancel") {
                            store.send(.cancelButtonTapped)
                        }
                        Spacer()
                        ProgressView()
                            .id(UUID())
                    }
                } else {
                    Button("Number fact") {
                        store.send(.factButtonTapped)
                    }
                }
                
                if let fact = store.currentFact {
                    Text(fact).padding(.vertical, 8)
                }
            }
            
            Section {
                Button("Number facts provided by numbersapi.com") {
                    self.openURL(URL(string: "http://numbersapi.com")!)
                }
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
            }
        }
        .buttonStyle(.borderless)
        .navigationTitle("Effect cancellation")
    }
}

#Preview {
    EffectsCancellationView(
        store: StoreOf<EffectsCancellation>(initialState: EffectsCancellation.State()) {
            EffectsCancellation()
        }
    )
}
