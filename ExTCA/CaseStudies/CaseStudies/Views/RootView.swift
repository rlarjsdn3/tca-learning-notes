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
