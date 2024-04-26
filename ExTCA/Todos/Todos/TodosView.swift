//
//  ContentView.swift
//  Todos
//
//  Created by 김건우 on 4/26/24.
//

import ComposableArchitecture
import SwiftUI

struct TodosView: View {
    
    // MARK: - Store
    @Bindable var store: StoreOf<Todos>
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Picker("Filter", selection: $store.filter.animation()) {
                    ForEach(Filter.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                List {
                    ForEach(store.scope(state: \.filteredTodos, action: \.todos)) { store in
                        TodoView(store: store)
                    }
                    .onDelete { store.send(.delete($0)) }
                    .onMove { store.send(.move($0, $1)) }
                }
            }
            .navigationTitle("Todos")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    EditButton()
                }
                
                ToolbarItem(placement: .automatic) {
                    Button("Clear Completed") {
                        store.send(.clearCompletedButtonTapped, animation: .default)
                    }
                    .disabled(!store.todos.contains(where: \.isComplete))
                }
                
                ToolbarItem(placement: .bottomBar) {
                    Button("Add Todo") {
                        store.send(.addTodoButtonTapped, animation: .default)
                    }
                }
            }
            .environment(\.editMode, $store.editMode)
        }
        
    }
}

// MARK: - Extensions
extension IdentifiedArray where ID == Todo.State.ID, Element == Todo.State {
    static let mock: Self = [
        Todo.State(
            description: "Check Mail",
            id: UUID(),
            isComplete: false
        ),
        Todo.State(
            description: "Buy Milk",
            id: UUID(),
            isComplete: false
        ),
        Todo.State(
            description: "Call Mon",
            id: UUID(),
            isComplete: true
        ),
    ]
}

// MARK: - Preview
#Preview {
    TodosView(
        store: .init(initialState: Todos.State(todos: .mock)) {
            Todos()
        }
    )
}
