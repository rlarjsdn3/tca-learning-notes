//
//  BindingsForm.swift
//  CaseStudies
//
//  Created by 김건우 on 4/30/24.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct BindingsForm {
    
    // MARK: - State
    @ObservableState
    struct State: Equatable {
        var sliderValue = 5.0
        var stepCount = 10
        var text = ""
        var toggleIsOn = false
    }
    
    // MARK: - Action
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case resetButtonTapped
    }
    
    // MARK: - Reducer
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(\.stepCount):
                state.sliderValue = min(state.sliderValue, Double(state.stepCount))
                return .none
                
            case .binding:
                return .none
                
            case .resetButtonTapped:
                state = State()
                return .none
            }
        }
    }
}

struct BindingsFormView: View {
    
    // MARK: - Store
    @Bindable var store: StoreOf<BindingsForm>
    
    // MARK: - Body
    var body: some View {
        List {
            HStack {
                TextField(
                    "Type here",
                    text: $store.text
                )
                .autocorrectionDisabled()
                .foregroundStyle(store.toggleIsOn ? Color.secondary : .primary)
            }
            .disabled(store.toggleIsOn)
            
            Toggle(
                "Disable other controls",
                isOn: $store.toggleIsOn
            )
            
            Stepper(
                "Max slider value: \(store.stepCount)",
                value: $store.stepCount
            )
            .disabled(store.toggleIsOn)
            
            HStack {
                Text("Slider value: \(Int(store.sliderValue))")
                
                Slider(
                    value: $store.sliderValue,
                    in: 0...Double(store.stepCount)
                )
                .disabled(store.toggleIsOn)
            }
            
            Button("Reset") {
                store.send(.resetButtonTapped)
            }
            .tint(.red)
        }
        .monospacedDigit()
        .navigationTitle("Bindings form")
    }
}

#Preview {
    BindingsFormView(
        store: StoreOf<BindingsForm>(initialState: BindingsForm.State()) {
            BindingsForm()
        }
    )
}
