//
//  ContentView.swift
//  Counter
//
//  Created by 김건우 on 4/23/24.
//

import ComposableArchitecture
import SwiftUI

struct CounterView: View {
    
    // MARK: - Properties
    let store: StoreOf<Counter>
    
    // MARK: - Body
    var body: some View {
        VStack {
            Text("\(store.count)")
                .font(.largeTitle)
                .padding()
                .background(Color.black.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            HStack {
                Button("-") {
                    store.send(.decrementButtonTapped)
                }
                .font(.largeTitle)
                .padding()
                .background(Color.black.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                
                Button("+") {
                    store.send(.incrementButtonTapped)
                }
                .font(.largeTitle)
                .padding()
                .background(Color.black.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
            Button(store.isTimerRunning ? "Stop Timer" : "Start Timer") {
                store.send(.toggleTimerButtonTapped)
            }
            .font(.largeTitle)
            .padding()
            .background(Color.black.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            Button("Fact") {
                store.send(.factButtonTapped)
            }
            .font(.largeTitle)
            .padding()
            .background(Color.black.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            if store.isLoading {
                ProgressView()
            } else if let fact = store.fact {
                Text(fact)
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                    .padding()
            }
        }
        .onAppear(perform: {
            store.send(.factButtonTapped)
        })
    }
}

// MARK: - Preview
#Preview {
    CounterView(
        store: Store(initialState: Counter.State()) {
            Counter()
        }
    )
}
