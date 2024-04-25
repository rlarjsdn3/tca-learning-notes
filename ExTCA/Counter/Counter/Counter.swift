//
//  Counter.swift
//  Counter
//
//  Created by 김건우 on 4/23/24.
//

import ComposableArchitecture
import Foundation

@Reducer
struct Counter {
    
    // MARK: - State
    @ObservableState
    struct State: Equatable {
        var count = 0
        var fact: String?
        var isLoading = false
        var isTimerRunning = false
    }
    
    // MARK: - Action
    enum Action {
        case decrementButtonTapped
        case factButtonTapped
        case factResponse(Result<String, Error>)
        case incrementButtonTapped
        case timerTick
        case toggleTimerButtonTapped
    }
    
    // MARK: - Id
    enum CancelID { case timer }
    
    // MARK: - Dependencies
    @Dependency(\.numberFact) var numberFact
    
    // MARK: - Reducer
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .decrementButtonTapped:
                state.count -= 1
                state.fact = nil
                return .none
                
            case .factButtonTapped:
                state.fact = nil
                state.isLoading = true
                return .run { [count = state.count] send in
                    await send(
                        .factResponse(Result { try await self.numberFact.fetch(count) }),
                        animation: .default
                    )
                }
                
            case let .factResponse(.success(fact)):
                state.fact = fact
                state.isLoading = false
                return .none
                
            case .factResponse(.failure):
                return .none
                
            case .incrementButtonTapped:
                state.count += 1
                state.fact = nil
                return .none
                
            case .timerTick:
                state.count += 1
                state.fact = nil
                return .none
                
            case .toggleTimerButtonTapped:
                state.isTimerRunning.toggle()
                if state.isTimerRunning {
                    return .run { send in
                        while true {
                            try await Task.sleep(for: .seconds(1))
                            await send(.timerTick)
                        }
                    }
                    .cancellable(id: CancelID.timer)
                } else {
                    return .cancel(id: CancelID.timer)
                }
            }
        }
    }
}
