//
//  NavigationStack.swift
//  CaseStudies
//
//  Created by 김건우 on 5/1/24.
//

import ComposableArchitecture
import SwiftUI

// MARK: - NavigationDemo
@Reducer
struct NavigationDemo {
    
    // MARK: - State
    @ObservableState
    struct State: Equatable {
        var path = StackState<Path.State>()
    }
    
    // MARK: - Action
    enum Action {
        case goBackToScreen(id: StackElementID)
        case goToABCButtonTapped
        case path(StackActionOf<Path>)
        case popToRoot
    }
    
    // MARK: - Path
    @Reducer(state: .equatable)
    enum Path {
        case screenA(ScreenA)
        case screenB(ScreenB)
        case screenC(ScreenC)
    }
    
    // MARK: - Reducer
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .goBackToScreen(id):
                state.path.pop(to: id)
                return .none
                
            case .goToABCButtonTapped:
                state.path.append(.screenA(ScreenA.State()))
                state.path.append(.screenB(ScreenB.State()))
                state.path.append(.screenC(ScreenC.State()))
                return .none
                
            case let .path(action):
                switch action {
                case .element(id: _, action: .screenB(.screenAButtonTapped)):
                    state.path.append(.screenA(ScreenA.State()))
                    return .none
                    
                case .element(id: _, action: .screenB(.screenBButtonTapped)):
                    state.path.append(.screenB(ScreenB.State()))
                    return .none
                    
                case .element(id: _, action: .screenB(.screenCButtonTapped)):
                    state.path.append(.screenC(ScreenC.State()))
                    return .none
                    
                default:
                    return .none
                }
                
            case .popToRoot:
                state.path.removeAll()
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
    
}

struct NavigationDemoView: View {
    
    // MARK: - Store
    @Bindable var store: StoreOf<NavigationDemo>
    
    // MARK: - Body
    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            List {
                Section {
                    NavigationLink(
                        "Go to screen A",
                        state: NavigationDemo.Path.State.screenA(ScreenA.State())
                    )
                    NavigationLink(
                        "Go to screen B",
                        state: NavigationDemo.Path.State.screenB(ScreenB.State())
                    )
                    NavigationLink(
                        "Go to screen C",
                        state: NavigationDemo.Path.State.screenC(ScreenC.State())
                    )
                }
                
                Section {
                    Button("Go to A → B → C") {
                        store.send(.goToABCButtonTapped)
                    }
                }
            }
        } destination: { store in
            switch store.case {
            case let .screenA(store):
                ScreenAView(store: store)
            case let .screenB(store):
                ScreenBView(store: store)
            case let .screenC(store):
                ScreenCView(store: store)
            }
        }
        .safeAreaInset(edge: .bottom) {
            FloatingMenuView(store: store)
        }
        .navigationTitle("Navigation Stack")
    }
}

// MARK: - Floating Menu
struct FloatingMenuView: View {
    
    // MARK: - Store
    let store: StoreOf<NavigationDemo>
    
    // MARK: - ViewState
    struct ViewState: Equatable {
        struct Screen: Equatable, Identifiable {
            let id: StackElementID
            let name: String
        }
        
        var currentStack: [Screen]
        var total: Int
        
        init(state: NavigationDemo.State) {
            self.total = 0
            self.currentStack = []
            
            for (id, element) in zip(state.path.ids, state.path) {
                switch element {
                case let .screenA(screenAState):
                    self.total += screenAState.count
                    self.currentStack.insert(Screen(id: id, name: "Screen A"), at: 0)
                case .screenB:
                    self.currentStack.insert(Screen(id: id, name: "Screen B"), at: 0)
                case let .screenC(screenCState):
                    self.total += screenCState.count
                    self.currentStack.insert(Screen(id: id, name: "Screen C"), at: 0)
                }
            }
        }
    }
    
    // MARK: - Body
    var body: some View {
        let viewState = ViewState(state: store.state)
        if viewState.currentStack.count > 0 {
            VStack(alignment: .center) {
                Text("Total count: \(viewState.total)")
                Button("Pop to root") {
                    store.send(.popToRoot, animation: .default)
                }
                Menu("Current stack") {
                    ForEach(viewState.currentStack) { screen in
                        Button("\(String(describing: screen.id)) \(screen.name)") {
                            store.send(.goBackToScreen(id: screen.id))
                        }
                        .disabled(screen == viewState.currentStack.first)
                    }
                }
                Button("Root") {
                    store.send(.popToRoot, animation: .default)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .padding(.bottom, 1)
            .transition(.opacity.animation(.default))
            .clipped()
            .shadow(color: .black.opacity(0.2), radius: 5, y: 5)
        }
    }
}

// MARK: - ScreenA
@Reducer
struct ScreenA {
    
    // MARK: - State
    @ObservableState
    struct State: Equatable { 
        var count = 0
        var fact: String?
        var isLoading = false
    }
    
    // MARK: - Action
    enum Action { 
        case decrementButtonTapped
        case incrementButtonTapped
        case dismissButtonTapped
        case factButtonTapped
        case factResponse(Result<String, Error>)
    }
    
    // MARK: - Dependencies
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.factClient) var factClient
    
    // MARK: - Reducer
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .decrementButtonTapped:
                state.count -= 1
                return .none
                
            case .incrementButtonTapped:
                state.count += 1
                return .none
                
            case .dismissButtonTapped:
                return .run { _ in
                    await self.dismiss()
                }
                
            case .factButtonTapped:
                state.isLoading = true
                return .run { [count = state.count] send in
                    await send(.factResponse(Result { try await self.factClient.fetch(count) }))
                }
                
            case let .factResponse(.success(fact)):
                state.isLoading = false
                state.fact = fact
                return .none
                
            case .factResponse(.failure):
                state.isLoading = false
                state.fact = nil
                return .none
            }
        }
    }
}

struct ScreenAView: View {
    
    // MARK: - Store
    let store: StoreOf<ScreenA>
    
    // MARK: - Body
    var body: some View {
        List {
            Section {
                HStack {
                    Text("\(store.count)")
                    Spacer()
                    Button {
                        store.send(.decrementButtonTapped)
                    } label: {
                        Image(systemName: "minus")
                    }
                    Button {
                        store.send(.incrementButtonTapped)
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                .buttonStyle(.borderless)
                
                Button {
                    store.send(.factButtonTapped)
                } label: {
                    HStack {
                        Text("Get fact")
                        if store.isLoading {
                            Spacer()
                            ProgressView()
                        }
                    }
                }
                
                if let fact = store.fact {
                    Text(fact)
                }
            }
            
            Section {
                Button("Dismiss") {
                    store.send(.dismissButtonTapped)
                }
            }
            
            Section {
                NavigationLink(
                    "Go to screen A",
                    state: NavigationDemo.Path.State.screenA(ScreenA.State(count: store.count))
                )
                NavigationLink(
                    "Go to screen B",
                    state: NavigationDemo.Path.State.screenB(ScreenB.State())
                )
                NavigationLink(
                    "Go to screen C",
                    state: NavigationDemo.Path.State.screenC(ScreenC.State())
                )
            }
        }
        .navigationTitle("Screen A")
    }
}

// MARK: - ScreenB
@Reducer
struct ScreenB {
    
    // MARK: - State
    @ObservableState
    struct State: Equatable { }
    
    // MARK: - Action
    enum Action { 
        case screenAButtonTapped
        case screenBButtonTapped
        case screenCButtonTapped
    }
    
    // MARK: - Reducer
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .screenAButtonTapped:
                return .none
                
            case .screenBButtonTapped:
                return .none
                
            case .screenCButtonTapped:
                return .none
            }
        }
    }
}

struct ScreenBView: View {
    
    // MARK: - Store
    let store: StoreOf<ScreenB>
    
    // MARK: - Body
    var body: some View {
        List {
            Button("Decoupled navigation to screen A") {
                store.send(.screenAButtonTapped)
            }
            Button("Decoupled navigation to screen B") {
                store.send(.screenBButtonTapped)
            }
            Button("Decoupled navigation to screen C") {
                store.send(.screenCButtonTapped)
            }
        }
        .navigationTitle("Screen B")
    }
}

// MARK: - ScreenC
@Reducer
struct ScreenC {
    
    // MARK: - State
    @ObservableState
    struct State: Equatable {
        var count = 0
        var isTimerRunning = false
    }
    
    // MARK: - Action
    enum Action { 
        case startButtonTapped
        case stopButtonTapped
        case timerTick
    }
    
    // MARK: - Dependencies
    @Dependency(\.mainQueue) var mainQueue
    enum CancelID { case timer }
    
    // MARK: - Reducer
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .startButtonTapped:
                state.isTimerRunning = true
                return .run { send in
                    for await _ in self.mainQueue.timer(interval: 1) {
                        await send(.timerTick)
                    }
                }
                .cancellable(id: CancelID.timer)
                .concatenate(with: .send(.stopButtonTapped))
                
            case .stopButtonTapped:
                state.isTimerRunning = false
                return .cancel(id: CancelID.timer)
                
            case .timerTick:
                state.count += 1
                return .none
            }
        }
    }
}

struct ScreenCView: View {
    
    // MARK: - Store
    let store: StoreOf<ScreenC>
    
    // MARK: - Body
    var body: some View {
        List {
            Section {
                Text("\(store.count)")
                if store.isTimerRunning {
                    Button("Stop timer") {
                        store.send(.stopButtonTapped)
                    }
                } else {
                    Button("Start timer") {
                        store.send(.startButtonTapped)
                    }
                }
            }
            
            Section {
                NavigationLink(
                    "Go to screen A",
                    state: NavigationDemo.Path.State.screenA(ScreenA.State())
                )
                NavigationLink(
                    "Go to screen B",
                    state: NavigationDemo.Path.State.screenB(ScreenB.State())
                )
                NavigationLink(
                    "Go to screen C",
                    state: NavigationDemo.Path.State.screenC(ScreenC.State())
                )
            }
        }
        .navigationTitle("Screen C")
    }
}

#Preview {
    NavigationDemoView(
        store: StoreOf<NavigationDemo>(initialState: NavigationDemo.State()) {
            NavigationDemo()
        }
    )
}
