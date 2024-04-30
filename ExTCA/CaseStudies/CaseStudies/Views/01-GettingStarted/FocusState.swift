//
//  FocusState.swift
//  CaseStudies
//
//  Created by 김건우 on 4/30/24.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct FocusDemo {
    
    // MARK: - State
    @ObservableState
    struct State: Equatable {
        var focusField: Field?
        var password: String = ""
        var username: String = ""
        
        enum Field: String, Hashable {
            case username, password
        }
    }
    
    // MARK: - Action
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case signInButtonTapped
    }
    
    // MARK: - Reducer
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
            case .signInButtonTapped:
                if state.username.isEmpty {
                    state.focusField = .username
                } else if state.password.isEmpty {
                    state.focusField = .password
                }
                return .none
            }
        }
    }
    
}

struct FocusDemoView: View {
    
    // MARK: - Store
    @Bindable var store: StoreOf<FocusDemo>
    
    // MARK: - Properties
    @FocusState var focusField: FocusDemo.State.Field?
    
    // MARK: - Body
    var body: some View {
        List {
            VStack {
                TextField("Username", text: $store.username)
                    .focused($focusField, equals: .username)
                SecureField("Password", text: $store.password)
                    .focused($focusField, equals: .password)
                Button("Sign In") {
                    store.send(.signInButtonTapped)
                }
                .buttonStyle(.borderedProminent)
            }
            .textFieldStyle(.roundedBorder)
        }
        .bind($store.focusField, to: $focusField)
        .navigationTitle("Focus demo")
    }
}

#Preview {
    FocusDemoView(
        store: StoreOf<FocusDemo>(initialState: FocusDemo.State()) {
            FocusDemo()
        }
    )
}
