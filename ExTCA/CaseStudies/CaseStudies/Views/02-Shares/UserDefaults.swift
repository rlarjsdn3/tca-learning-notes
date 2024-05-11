//
//  UserDefaults.swift
//  CaseStudies
//
//  Created by 김건우 on 5/11/24.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct SharedStateUserDefaults {
    
    // MARK: - Tab
    enum Tab { case counter, profile }
    
    // MARK: - State
    @ObservableState
    struct State: Equatable {
        var currentTab = Tab.counter
        var counter = CounterTab.State()
        var profile = ProfileTab.State()
    }
    
    // MARK: - Action
    enum Action {
        case counter(CounterTab.Action)
        case profile(ProfileTab.Action)
        case selectedTab(Tab)
    }
    
    // MARK: - Reducer
    var body: some ReducerOf<Self> {
        Scope(state: \.counter, action: \.counter) {
            CounterTab()
        }
        Scope(state: \.profile, action: \.profile) {
            ProfileTab()
        }
        
        Reduce { state, action in
            switch action {
            case .counter, .profile:
                return .none
                
            case let .selectedTab(tab):
                state.currentTab = tab
                return .none
            }
        }
    }
}

extension SharedStateUserDefaults {
    
    // MARK: - CounterTab
    @Reducer
    struct CounterTab {
        
        // MARK: - State
        @ObservableState
        struct State: Equatable {
            @Presents var alert: AlertState<Action.Alert>?
            @Shared(.count) var count = 0
        }
        
        // MARK: - Action
        enum Action {
            case alert(PresentationAction<Alert>)
            case decrementButtonTapped
            case incrementButtonTapped
            case isPrimeButtonTapped
            
            enum Alert: Equatable { }
        }
        
        // MARK: - Reducer
        var body: some ReducerOf<Self> {
            Reduce { state, action in
                switch action {
                case .alert:
                    return .none
                    
                case .decrementButtonTapped:
                    state.count += 1
                    return .none
                    
                case .incrementButtonTapped:
                    state.count -= 1
                    return .none
                    
                case .isPrimeButtonTapped:
                    state.alert = AlertState {
                        TextState(
                            isPrime(state.count)
                            ? "👍 The number \(state.count) is prime!"
                            : "👎 The number \(state.count) is not prime :("
                        )
                    }
                    return .none
                }
            }
            .ifLet(\.$alert, action: \.alert)
        }
    }
}

extension SharedStateUserDefaults {
    
    // MARK: - RrofileTab
    @Reducer
    struct ProfileTab {
        
        // MARK: - State
        @ObservableState
        struct State: Equatable {
            @Shared(.count) var count = 0
        }
        
        // MARK: - Action
        enum Action {
            case resetStatsButtonTapped
        }
        
        // MARK: - Body
        var body: some ReducerOf<Self> {
            Reduce { state, action in
                switch action {
                case .resetStatsButtonTapped:
                    state.count = 0
                    return .none
                }
            }
        }
    }
}

// MARK: - FileStorageView
struct SharedStateUserDefaultsView: View {
    
    // MARK: - Store
    @Bindable var store: StoreOf<SharedStateUserDefaults>
    
    // MARK: - Body
    var body: some View {
        TabView(selection: $store.currentTab.sending(\.selectedTab)) {
            CounterTabView(store: store.scope(state: \.counter, action: \.counter))
                .tag(SharedStateFileStorage.Tab.counter)
                .tabItem { Text("Counter") }
            
            ProfileTabView(store: store.scope(state: \.profile, action: \.profile))
                .tag(SharedStateFileStorage.Tab.profile)
                .tabItem { Text("Profile") }
        }
        .navigationTitle("Shared State Demo")
    }
}

// MARK: - CounterTabView
private struct CounterTabView: View {
    
    // MARK: - Store
    @Bindable var store: StoreOf<SharedStateUserDefaults.CounterTab>
    
    // MARK: - Body
    var body: some View {
        List {
            VStack(spacing: 16) {
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

                    Button("Is this prime?") {
                        store.send(.isPrimeButtonTapped)
                    }
                }
            }
            .buttonStyle(.borderless)
            .alert($store.scope(state: \.alert, action: \.alert))
        }
    }
}

// MARK: - ProfileTabView
private struct ProfileTabView: View {
    
    // MARK: - Store
    let store: StoreOf<SharedStateUserDefaults.ProfileTab>
    
    // MARK: - Body
    var body: some View {
        List {
            VStack(spacing: 16) {
                Text("Current count: \(store.count)")
                Button("Reset") {
                    store.send(.resetStatsButtonTapped)
                }
            }
            .buttonStyle(.borderless)
        }
    }
}

// MARK: - PersistencyKey
extension PersistenceReaderKey where Self == AppStorageKey<Int> {
    fileprivate static var count: Self {
        appStorage("count")
    }
}

// MARK: - Helpers
private func isPrime(_ p: Int) -> Bool {
    if p <= 1 { return false }
    if p <= 3 { return true }
    for i in 2...Int(sqrtf(Float(p))) {
        if p % i == 0 { return false }
    }
    return true
}


// MARK: - Preview
#Preview {
    SharedStateUserDefaultsView(
        store: StoreOf<SharedStateUserDefaults>(initialState: SharedStateUserDefaults.State()) {
            SharedStateUserDefaults()
        }
    )
}
