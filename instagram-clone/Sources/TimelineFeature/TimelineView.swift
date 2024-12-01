import Foundation
import SwiftUI
import ComposableArchitecture
import AppUI

@Reducer
public struct TimelineReducer {
	public init() {}
	@ObservableState
	public struct State: Equatable {
		public init() {}
	}
	public enum Action: BindableAction {
		case binding(BindingAction<State>)
	}
	public var body: some ReducerOf<Self> {
		BindingReducer()
		Reduce { state, action in
			switch action {
			case .binding:
				return .none
			}
		}
	}
}

public struct TimelineView: View {
	@Bindable var store: StoreOf<TimelineReducer>
	@Environment(\.textTheme) var textTheme
	public init(store: StoreOf<TimelineReducer>) {
		self.store = store
	}
	public var body: some View {
		Text("Timelin")
			.font(textTheme.headlineSmall.font)
	}
}

