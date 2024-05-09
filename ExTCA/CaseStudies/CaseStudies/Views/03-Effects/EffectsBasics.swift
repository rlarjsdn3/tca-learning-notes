//
//  Basics.swift
//  CaseStudies
//
//  Created by 김건우 on 5/6/24.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct EffectsBasics {
    
    // MARK: - State
    @ObservableState
    struct State: Equatable {
        var count = 0
        var isNumberFactRequestInFlight = false
        var numberFact: String?
    }
    
    // MARK: - Action
    enum Action {
        case decrementButtonTapped
        case decrementDelayResponse
        case incrementButtonTapped
        case numberFactButtonTapped
        case numberFactResponse(Result<String, Error>)
    }
    
    // MARK: - Dependencies
    @Dependency(\.continuousClock) var clock
    @Dependency(\.factClient) var factClient
    
    // MARK: - Id
    private enum CancelID { case delay }
    
    // MARK: - Reducer
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .decrementButtonTapped:
                state.count -= 1
                state.numberFact = nil
                return state.count >= 0
                ? .none
                : .run { send in
                    try await self.clock.sleep(for: .seconds(1))
                    await send(.decrementDelayResponse)
                }
                .cancellable(id: CancelID.delay)
                
            case .decrementDelayResponse:
                if state.count < 0 {
                    state.count += 1
                }
                return .none
                
            case .incrementButtonTapped:
                state.count += 1
                state.numberFact = nil
                return state.count >= 0
                ? .cancel(id: CancelID.delay)
                : .none
                
            case .numberFactButtonTapped:
                state.isNumberFactRequestInFlight = true
                state.numberFact = nil
                return .run { [count = state.count] send in
                    await send(.numberFactResponse(Result { try await self.factClient.fetch(count) }))
                }
                
            case let .numberFactResponse(.success(response)):
                state.isNumberFactRequestInFlight = false
                state.numberFact = response
                return .none
                
            case .numberFactResponse(.failure):
                state.isNumberFactRequestInFlight = false
                return .none
            }
        }
    }
}

struct EffectsBasicsView: View {
    
    // MARK: - Store
    let store: StoreOf<EffectsBasics>
    
    // MARK: - Environment
    @Environment(\.openURL) var openURL
    
    // MARK: - Body
    var body: some View {
        List {
            Section {
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
                
                Button("Number fact") {
                    store.send(.numberFactButtonTapped)
                }
                .frame(maxWidth: .infinity)
                
                if store.isNumberFactRequestInFlight {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .id(UUID())
                }
                
                if let numberFact = store.numberFact {
                    Text(numberFact)
                }
            }
            
            Section {
                Button("Number facts provided by numbersapi.com") {
                    openURL(URL(string: "http://numbersapi.com")!)
                }
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
            }
        }
        .buttonStyle(.borderless)
        .navigationTitle("Effects")
    }
}

#Preview {
    EffectsBasicsView(
        store: StoreOf<EffectsBasics>(initialState: EffectsBasics.State()) {
            EffectsBasics()
        }
    )
}
