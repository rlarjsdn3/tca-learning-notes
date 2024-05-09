//
//  Timers.swift
//  CaseStudies
//
//  Created by 김건우 on 5/9/24.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct Timers {
    
    // MARK: - State
    @ObservableState
    struct State: Equatable {
        var isTimerActive = false
        var secondsElapsed = 0
    }
    
    // MARK: - Action
    enum Action {
        case onDisappear
        case timerTick
        case toggleTimerButtonTapped
    }
    
    // MARK: - Dependencies
    @Dependency(\.continuousClock) var clock
    
    // MARK: - Id
    private enum CancelID { case timer }
    
    // MARK: - Reducer
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onDisappear:
                return .cancel(id: CancelID.timer)
                
            case .timerTick:
                state.secondsElapsed += 1
                return .none
                
            case .toggleTimerButtonTapped:
                state.isTimerActive.toggle()
                return .run { [isTimerActive = state.isTimerActive] send in
                    guard isTimerActive else { return }
                    for await _ in self.clock.timer(interval: .seconds(1)) {
                        await send(.timerTick, animation: .interpolatingSpring(stiffness: 300, damping: 40))
                    }
                }
                .cancellable(id: CancelID.timer, cancelInFlight: true)
            }
        }
    }
}

struct TimersView: View {
    
    // MARK: - Store
    let store: StoreOf<Timers>
    
    // MARK: - Body
    var body: some View {
        List {
            ZStack {
                Circle()
                    .fill(
                        AngularGradient(
                            gradient: Gradient(
                                colors: [
                                    .blue.opacity(0.3),
                                    .blue,
                                    .blue,
                                    .green,
                                    .green,
                                    .yellow,
                                    .yellow,
                                    .red,
                                    .red,
                                    .purple,
                                    .purple,
                                    .purple.opacity(0.3),
                                ]
                            ),
                            center: .center
                        )
                    )
                    .rotationEffect(.degrees(-90))
                
                GeometryReader { proxy in
                    Path { path in
                        path.move(
                            to: CGPoint(
                                x: proxy.size.width / 2,
                                y: proxy.size.height / 2
                            )
                        )
                        path.addLine(
                            to: CGPoint(
                                x: proxy.size.width / 2,
                                y: 0
                            )
                        )
                    }
                    .stroke(.primary, lineWidth: 3)
                    .rotationEffect(.degrees(Double(store.secondsElapsed) * 360) / 60)
                }
            }
            .aspectRatio(1, contentMode: .fit)
            .frame(minWidth: 280)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            
            Button {
                store.send(.toggleTimerButtonTapped)
            } label: {
                Text(store.isTimerActive ? "Stop" : "Start")
                    .padding(8)
            }
            .frame(maxWidth: .infinity)
            .tint(store.isTimerActive ? Color.red : .accentColor)
            .buttonStyle(.borderedProminent)
        }
        .navigationTitle("Timers")
        .onDisappear {
            store.send(.onDisappear)
        }
    }
}

// MARK: - Preview
#Preview {
    TimersView(
        store: StoreOf<Timers>(initialState: Timers.State()) {
            Timers()
        }
    )
}
