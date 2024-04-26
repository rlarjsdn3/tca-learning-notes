//
//  Todos.swift
//  Todos
//
//  Created by 김건우 on 4/26/24.
//

import ComposableArchitecture
import SwiftUI

enum Filter: String, CaseIterable, Hashable {
    case all = "All"
    case active = "Active"
    case completed = "Completed"
}

@Reducer
struct Todos {
    
    // MARK: - State
    @ObservableState
    struct State: Equatable {
        var editMode: EditMode = .inactive
        var filter: Filter = .all
        var todos: IdentifiedArrayOf<Todo.State> = []
        
        var filteredTodos: IdentifiedArrayOf<Todo.State> {
            switch filter {
            case .all: return self.todos
            case .active: return self.todos.filter { !$0.isComplete }
            case .completed: return self.todos.filter(\.isComplete)
            }
        }
    }
    
    // MARK: - Action
    enum Action: BindableAction {
        case addTodoButtonTapped
        case binding(BindingAction<State>)
        case clearCompletedButtonTapped
        case delete(IndexSet)
        case move(IndexSet, Int)
        case sortCompletedTodos
        case todos(IdentifiedActionOf<Todo>)
    }
    
    // MARK: - Dependencies
    @Dependency(\.continuousClock) var clock
    @Dependency(\.uuid) var uuid
    
    // MARK: - Id
    private enum CancelID { case todoCompletion }
    
    // MARK: - Reducer
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .addTodoButtonTapped:
                state.todos.insert(Todo.State(id: self.uuid()), at: 0)
                return .none
                
            case .binding:
                return .none
                
            case .clearCompletedButtonTapped:
                state.todos.removeAll(where: \.isComplete)
                return .none
                
            case let .delete(indexSet):
                let filteredTodos = state.filteredTodos
                for index in indexSet {
                    state.todos.remove(id: filteredTodos[index].id)
                }
                return .none
                
            case var .move(source, destination):
                if state.filter == .completed {
                    source = IndexSet(
                        source
                            .map { state.filteredTodos[$0] }
                            .compactMap { state.todos.index(id: $0.id) }
                    )
                }
                destination =
                (destination < state.filteredTodos.endIndex
                  ? state.todos.index(id: state.filteredTodos[destination].id)
                  : state.todos.endIndex)
                ?? destination
                
                state.todos.move(fromOffsets: source, toOffset: destination)
                
                return .run { send in
                    try await self.clock.sleep(for: .milliseconds(100))
                    await send(.sortCompletedTodos, animation: .default)
                }
                
            case .sortCompletedTodos:
                state.todos.sort { $1.isComplete && !$0.isComplete }
                return .none
                
            case .todos(.element(id: _, action: .binding(\.isComplete))):
                return .run { send in
                    try await self.clock.sleep(for: .seconds(1))
                    await send(.sortCompletedTodos, animation: .default)
                }
                .cancellable(id: CancelID.todoCompletion, cancelInFlight: true)
                
            case .todos:
                return .none
            }
        }
        .forEach(\.todos, action: \.todos) {
            Todo()
        }
    }
    
}
