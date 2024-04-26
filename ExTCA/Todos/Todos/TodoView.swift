//
//  TodoView.swift
//  Todos
//
//  Created by 김건우 on 4/26/24.
//

import ComposableArchitecture
import SwiftUI

struct TodoView: View {
    
    // MARK: - Store
    @Bindable var store: StoreOf<Todo>
    
    // MARK: - Body
    var body: some View {
        HStack {
            Button {
                store.isComplete.toggle()
            } label: {
                Image(systemName: store.isComplete ? "checkmark.square" : "square")
            }
            .buttonStyle(.plain)
            
            TextField("Untitled Todo", text: $store.description)
        }
        .foregroundStyle(store.isComplete ? Color.gray : Color.black)
    }
}

// MARK: - Preview
#Preview {
    TodoView(
        store: .init(initialState: Todo.State(id: UUID())) {
            Todo()
        }
    )
}
