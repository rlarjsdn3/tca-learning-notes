//
//  TodosApp.swift
//  Todos
//
//  Created by 김건우 on 4/26/24.
//

import ComposableArchitecture
import SwiftUI

@main
struct TodosApp: App {
    
    // MARK: - Store
    static let store = StoreOf<Todos>(initialState: Todos.State()) {
        Todos()
    }
    
    // MARK: - Body
    var body: some Scene {
        WindowGroup {
            TodosView(store: TodosApp.store)
        }
    }
}
