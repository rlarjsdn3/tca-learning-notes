//
//  LongLivingEffect.swift
//  CaseStudies
//
//  Created by 김건우 on 5/9/24.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct LongLivingEffect {
    
    // MARK: - State
    @ObservableState
    struct State: Equatable {
        var screenshotCount = 0
    }
    
    // MARK: - Action
    enum Action {
        case task
        case userDidTakeScreenshotNotification
    }
    
    // MARK: - Dependencies
    @Dependency(\.screenshots) var screenshots
    
    // MARK: - Reducer
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .task:
                return .run { send in
                    for await _ in await self.screenshots() {
                        await send(.userDidTakeScreenshotNotification)
                    }
                }
                
            case .userDidTakeScreenshotNotification:
                state.screenshotCount += 1
                return .none
            }
        }
    }
}

struct LongLivingEffectView: View {
    
    // MARK: - Store
    let store: StoreOf<LongLivingEffect>
    
    // MARK: - Body
    var body: some View {
        List {
            Text("A screenshot of this screen has been take \(store.screenshotCount) times.")
                .font(.headline)
            
            Section {
                NavigationLink {
                    detailView
                } label: {
                    Text("Navigate to another screen")
                }
            }
        }
        .navigationTitle("Long-living effects")
        .task { await store.send(.task).finish() }
    }
}

var detailView: some View {
  Text(
    """
    Take a screenshot of this screen a few times, and then go back to the previous screen to see \
    that those screenshots were not counted.
    """
  )
  .padding(.horizontal, 64)
  .navigationBarTitleDisplayMode(.inline)
}


// MARK: - Dependency
private enum ScreenShotsKey: DependencyKey {
    static let liveValue: @Sendable () async -> AsyncStream<Void> = {
        await AsyncStream(
            NotificationCenter.default
                .notifications(named: UIApplication.userDidTakeScreenshotNotification)
                .map { _ in}
        )
    }
}

extension DependencyValues {
    var screenshots: @Sendable () async -> AsyncStream<Void> {
        get { self[ScreenShotsKey.self] }
        set { self[ScreenShotsKey.self] = newValue }
    }
}


#Preview {
    LongLivingEffectView(
        store: StoreOf<LongLivingEffect>(initialState: LongLivingEffect.State()) {
            LongLivingEffect()
        }
    )
}
