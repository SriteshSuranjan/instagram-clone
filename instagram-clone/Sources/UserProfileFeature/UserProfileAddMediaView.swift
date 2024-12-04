import SwiftUI
import ComposableArchitecture
import AppUI

public enum ProfileAddMediaType {
	case reels
	case posts
	case stories
}

@Reducer
public struct UserProfileAddMediaReducer {
	public init() {}
	@ObservableState
	public struct State: Equatable {
		public init() {}
	}
	public enum Action: BindableAction {
		case binding(BindingAction<State>)
		case delegate(Delegate)
		public enum Delegate {
			case onTapAddMediaButton(ProfileAddMediaType)
		}
	}
	public var body: some ReducerOf<Self> {
		BindingReducer()
		Reduce { state, action in
			switch action {
			case .binding:
				return .none
			case .delegate:
				return .none
			}
		}
	}
}

public struct UserProfileAddMediaView: View {
	let store: StoreOf<UserProfileAddMediaReducer>
	@Environment(\.colorScheme) var colorScheme
	@Environment(\.textTheme) var textTheme
	public init(store: StoreOf<UserProfileAddMediaReducer>) {
		self.store = store
	}
	public var body: some View {
		VStack {
			Text("Create")
				.font(textTheme.headlineSmall.font)
			Divider()
			VStack(spacing: AppSpacing.spaceUnit) {
				Button {
					store.send(.delegate(.onTapAddMediaButton(.reels)))
				} label: {
					HStack(spacing: AppSpacing.spaceUnit) {
						Image(systemName: "play.rectangle.on.rectangle.fill")
							.imageScale(.large)
						Text("Reels")
					}
					.contentShape(.rect)
				}
				.frame(height: 50)
				.frame(maxWidth: .infinity, alignment: .leading)
				Button {
					store.send(.delegate(.onTapAddMediaButton(.posts)))
				} label: {
					HStack(spacing: AppSpacing.spaceUnit) {
						Image(systemName: "photo.badge.plus")
							.imageScale(.large)
						Text("Posts")
						Spacer()
					}
					.contentShape(.rect)
				}
				.frame(height: 50)
				.frame(maxWidth: .infinity, alignment: .leading)
				Button {
					store.send(.delegate(.onTapAddMediaButton(.stories)))
				} label: {
					HStack(spacing: AppSpacing.spaceUnit) {
						Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90.camera")
							.imageScale(.large)
						Text("Stories")
						Spacer()
					}
					.contentShape(.rect)
				}
				.frame(height: 50)
				.frame(maxWidth: .infinity, alignment: .leading)
			}
			.buttonStyle(.plain)
			.foregroundStyle(Assets.Colors.bodyColor)
			.font(textTheme.bodyLarge.font)
			.padding(.horizontal, AppSpacing.lg)
		}
	}
}
