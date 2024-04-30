//
//  Bindings-Basic.swift
//  CaseStudies
//
//  Created by 김건우 on 4/30/24.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct BindingsBasic {
    
    // MARK: - State
    @ObservableState
    struct State: Equatable {
        var sliderValue = 5.0
        var stepCount = 10
        var text = ""
        var toggleIsOn = false
    }
    
    // MARK: - Action
    enum Action {
        case sliderValueChanged(Double)
        case stepCountChanged(Int)
        case textChanged(String)
        case toggleChanged(isOn: Bool)
        
    }
    
    // MARK: - Reducer
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .sliderValueChanged(value):
                state.sliderValue = value
                return .none
                
            case let .stepCountChanged(count):
                state.stepCount = count
                return .none
                
            case let .textChanged(text):
                state.text = text
                return .none
                
            case let .toggleChanged(isOn):
                state.toggleIsOn = isOn
                return .none
            }
        }
    }
    
}

struct BindingsBasicView: View {
    
    // MARK: - Store
    @Bindable var store: StoreOf<BindingsBasic>
    
    // MARK: - Body
    var body: some View {
        List {
            HStack {
                TextField("Type here", text: $store.text.sending(\.textChanged))
                    .autocorrectionDisabled()
                    .foregroundStyle(store.toggleIsOn ? Color.secondary : .primary)
            }
            .disabled(store.toggleIsOn)
            
            Toggle(
                "Disable other controls",
                isOn: $store.toggleIsOn.sending(\.toggleChanged)
            )
            
            Stepper(
                "Max slider value: \(store.stepCount)",
                value: $store.stepCount.sending(\.stepCountChanged)
            )
            .disabled(store.toggleIsOn)
            
            HStack {
                Text("Slider value: \(Int(store.sliderValue))")
                Slider(
                    value: $store.sliderValue.sending(\.sliderValueChanged),
                    in: 0...Double(store.stepCount)
                )
                .tint(.accentColor)
            }
            .disabled(store.toggleIsOn)
        }
        .monospacedDigit()
        .navigationTitle("Bindings baiscs")
    }
}

#Preview {
    BindingsBasicView(
        store: StoreOf<BindingsBasic>(initialState: BindingsBasic.State()) {
            BindingsBasic()
        }
    )
}
