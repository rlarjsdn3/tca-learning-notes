//
//  ContentView.swift
//  CaseStudies
//
//  Created by 김건우 on 4/27/24.
//

import ComposableArchitecture
import SwiftUI

struct RootView: View {
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink("Alert & Dialogs") {
                        AlertsAndConfirmationDialogView(
                            store: StoreOf<AlertsAndConfirmationDialog>(initialState: AlertsAndConfirmationDialog.State()) {
                                AlertsAndConfirmationDialog()
                            }
                        )
                    }
                    
                    NavigationLink("Animations") {
                        AnimationsView(
                            store: StoreOf<Animations>(initialState: Animations.State()) {
                                Animations()
                            }
                        )
                    }
                    
                    NavigationLink("Bindings Basic") {
                        BindingsBasicView(
                            store: StoreOf<BindingsBasic>(initialState: BindingsBasic.State()) {
                                BindingsBasic()
                            }
                        )
                    }
                    
                    NavigationLink("Bindings Form") {
                        BindingsFormView(
                            store: StoreOf<BindingsForm>(initialState: BindingsForm.State()) {
                                BindingsForm()
                            }
                        )
                    }
                    
                    NavigationLink("Counter") {
                        CounterDemoView(
                            store: StoreOf<Counter>(initialState: Counter.State()) {
                                Counter()
                            }
                        )
                    }
                    
                    NavigationLink("TowCounters") {
                        TwoCountersView(
                            store: StoreOf<TwoCounters>(initialState: TwoCounters.State()) {
                                TwoCounters()
                            }
                        )
                    }
                    
                    NavigationLink("Focus State") {
                        FocusDemoView(
                            store: StoreOf<FocusDemo>(initialState: FocusDemo.State()) {
                                FocusDemo()
                            }
                        )
                    }
                    
                    NavigationLink("Optional Basics") {
                        OptionalBasicsView(
                            store: StoreOf<OptionalBasics>(initialState: OptionalBasics.State()) {
                                OptionalBasics()
                            }
                        )
                    }
                } header: {
                    Text("Getting Started")
                }
            }
            .navigationTitle("CaseStudies")
        }
    }
}

#Preview {
    RootView()
}
