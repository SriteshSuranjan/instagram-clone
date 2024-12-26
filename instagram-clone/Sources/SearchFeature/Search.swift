import Foundation
import SwiftUI
import ComposableArchitecture
import Shared
import InstagramClient
import AppUI
import InstagramBlocksUI

@Reducer
public struct SearchReducer {
	public init() {}
	@ObservableState
	public struct State: Equatable {
		var users: [User] = []
		var query: String = ""
		public init() {}
	}
	public enum Action: BindableAction {
		case binding(BindingAction<State>)
		case updateQuery(String)
		case usersQueryResult([User])
		case onTapBackButton
	}
	
	@Dependency(\.instagramClient.searchClient.searchUsers) var searchUsers
	
	public var body: some ReducerOf<Self> {
		BindingReducer()
		Reduce { state, action in
			switch action {
			case .binding:
				return .none
			case .onTapBackButton:
				return .run { _ in
					@Dependency(\.dismiss) var dismiss
					await dismiss()
				}
			case let .updateQuery(newQuery):
				guard state.query != newQuery else {
					return .none
				}
				state.query = newQuery
				return .run { [query = state.query] send in
					let users = try await searchUsers(query, 8, 0, [])
					await send(.usersQueryResult(users))
				}
				.debounce(id: "QueryUsers", for: .milliseconds(300), scheduler: DispatchQueue.main)
			case let .usersQueryResult(users):
				state.users = users
				return .none
			}
		}
	}
}

public struct SearchView: View {
	@Bindable var store: StoreOf<SearchReducer>
	@Environment(\.textTheme) var textTheme
	@Environment(\.colorScheme) var colorScheme
	public init(store: StoreOf<SearchReducer>) {
		self.store = store
	}
	public var body: some View {
		VStack {
			HStack(spacing: AppSpacing.xlg) {
				Button {
					store.send(.onTapBackButton)
				} label: {
					Image(systemName: "chevron.backward")
						.font(textTheme.headlineMedium.font)
						.foregroundStyle(Assets.Colors.bodyColor)
				}
				TextField("Search", text: $store.query.sending(\.updateQuery))
					.appTextField(
						foregroundColor: Assets.Colors.bodyColor,
						accentColor: Assets.Colors.bodyColor,
						backgroundColor: Assets.Colors.customReversedAdaptiveColor(colorScheme, light: Assets.Colors.brightGray, dark: Assets.Colors.dark),
						keyboardType: .default,
						returnKeyType: .next
					)
					.padding()
			}
			
			ScrollView {
				LazyVStack {
					ForEach(store.users) { user in
						Button {
							
						} label: {
							HStack {
								UserProfileAvatar(
									userId: user.id,
									avatarUrl: user.avatarUrl,
									radius: 26
								)
								.foregroundStyle(Assets.Colors.bodyColor)
								VStack(alignment: .leading) {
									Text(user.displayUsername)
										.font(textTheme.labelLarge.font)
										.fontWeight(.medium)
										.foregroundStyle(Assets.Colors.bodyColor)
									Text(user.displayFullName)
										.font(textTheme.labelLarge.font)
										.fontWeight(.medium)
										.foregroundStyle(Assets.Colors.gray)
								}
								Spacer()
							}
						}
					}
				}
			}
		}
		.padding(.horizontal, AppSpacing.lg)
		.toolbar(.hidden, for: .navigationBar)
	}
}

#Preview {
	SearchView(
		store: Store(
			initialState: SearchReducer.State(),
			reducer: { SearchReducer() }
		)
	)
}
