//
//  Todos.swift
//  Todos
//
//  Created by 김건우 on 4/26/24.
//

import ComposableArchitecture
import Foundation

@Reducer
struct Todo {
    
    // MARK: - State
    @ObservableState
    struct State: Equatable, Identifiable {
        var description = ""
        let id: UUID
        var isComplete = false
    }
    
    // MARK: - Action
    enum Action: BindableAction, Sendable {
        case binding(BindingAction<State>)
    }
    
    // MARK: - Reducer
    var body: some ReducerOf<Self> {
        BindingReducer()
    }
    
}
