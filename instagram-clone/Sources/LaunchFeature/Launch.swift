import Foundation
import SwiftUI
import ComposableArchitecture
import AppUI

@Reducer
public struct LaunchReducer {
	public init() {}
	@ObservableState
	public struct State: Equatable {
		public init() {}
	}
	public enum Action {
		
	}
	public var body: some ReducerOf<Self> {
		EmptyReducer()
	}
}

public struct LaunchView: View {
	let store: StoreOf<LaunchReducer>
	public init(store: StoreOf<LaunchReducer>) {
		self.store = store
	}
	public var body: some View {
		ZStack {
			Assets.Colors.background
			Assets.Images.logo
				.view(
					width: .infinity,
					tint: Assets.Colors.bodyColor
				)
				.padding(.horizontal)
		}
		.ignoresSafeArea()
	}
}

#Preview {
	LaunchView(
		store: Store(
			initialState: LaunchReducer.State(),
			reducer: { LaunchReducer() }
		)
	)
}
