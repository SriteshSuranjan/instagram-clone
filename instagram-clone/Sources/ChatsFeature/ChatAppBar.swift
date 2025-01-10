import Foundation
import AppUI
import ComposableArchitecture
import SwiftUI
import InstagramBlocksUI
import Shared

@Reducer
public struct ChatAppBarReducer {
	public init() {}
	@ObservableState
	public struct State: Equatable {
		var participant: User
		public init(participant: User) {
			self.participant = participant
		}
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

public struct ChatAppBarView: View {
	let store: StoreOf<ChatAppBarReducer>
	@Environment(\.textTheme) var textTheme
	@Environment(\.dismiss) var dismiss
	public init(store: StoreOf<ChatAppBarReducer>) {
		self.store = store
	}
	public var body: some View {
		HStack(spacing: 0) {
			Button {
				dismiss()
			} label: {
				Image(systemName: "chevron.backward")
					.font(textTheme.headlineMedium.font)
			}
			.padding(.leading, AppSpacing.lg)
			.padding(.trailing, AppSpacing.xlg)
			UserProfileAvatar(
				userId: store.participant.id,
				avatarUrl: store.participant.avatarUrl,
				radius: 32
			)
			.padding(.trailing, AppSpacing.lg)
			VStack(alignment: .leading) {
				Text(store.participant.displayUsername)
					.font(textTheme.titleLarge.font)
					.fontWeight(.semibold)
				Text("Online")
					.font(textTheme.bodyLarge.font)
			}
			Spacer()
		}
		.foregroundStyle(Assets.Colors.bodyColor)
	}
}
