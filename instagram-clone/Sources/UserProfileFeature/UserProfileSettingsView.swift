import SwiftUI
import ComposableArchitecture
import AppUI
import UserClient

@Reducer
public struct UserProfileSettingsReducer {
	public init() {}
	@ObservableState
	public struct State: Equatable {
		@Presents var alert: AlertState<Action.Alert>?
		public init() {}
	}
	public enum Action: BindableAction {
		case alert(PresentationAction<Alert>)
		case binding(BindingAction<State>)
		case onTapLogoutButton
		
		@CasePathable
		public enum Alert: Equatable {
			case confirmToLogout
		}
	}
	
	@Dependency(\.userClient.authClient) var authClient
	
	public var body: some ReducerOf<Self> {
		BindingReducer()
		Reduce { state, action in
			switch action {
			case .alert(.presented(.confirmToLogout)):
				return .run { _ in
					try await authClient.logOut()
				}
			case .alert:
				return .none
			case .binding:
				return .none
			case .onTapLogoutButton:
				state.alert = AlertState(
					title: {
						TextState("Log out")
					},
					actions: {
						ButtonState(role: .cancel) {
							TextState("Cancel")
						}
						ButtonState(role: .destructive, action: .send(.confirmToLogout)) {
							TextState("Log out")
						}
					},
					message: {
						TextState("Are you sure want to log out?")
					}
				)
				return .none
			}
		}
		.ifLet(\.$alert, action: \.alert)
	}
}

public struct UserProfileSettingsView: View {
	@Bindable var store: StoreOf<UserProfileSettingsReducer>
	@Environment(\.colorScheme) var colorScheme
	@Environment(\.textTheme) var textTheme
	public init(store: StoreOf<UserProfileSettingsReducer>) {
		self.store = store
	}
	var themeValue: String {
		switch colorScheme {
		case .dark: return "Dark"
		case .light: return "Light"
		@unknown default: return "Unknown"
		}
	}
	public var body: some View {
		VStack(spacing: 16) {
			UserProfileSettinsItemView(
				value: "English",
				title: "Language",
				selections: {
					ForEach(["English", "中文"], id: \.self) { language in
						Button(language) {
							
						}
					}
				}) {
					
				}
			UserProfileSettinsItemView(
				value: themeValue,
				title: "Theme",
				selections: {
					ForEach(["System", "Dark", "Light"], id: \.self) { theme in
						Button(theme) {
							
						}
					}
				}) {
					
				}
			Button(role: .destructive) {
				store.send(.onTapLogoutButton)
			} label: {
				Label("Log out", systemImage: "rectangle.portrait.and.arrow.right")
					.imageScale(.large)
			}
			.frame(height: 50)
			.frame(maxWidth: .infinity, alignment: .leading)
		}
		.font(textTheme.bodyLarge.font.bold())
		.padding(.horizontal, AppSpacing.lg)
		.alert($store.scope(state: \.alert, action: \.alert))
	}
}

public struct UserProfileSettinsItemView<Selections: View>: View {
	let value: String
	let title: String
	let selections: () -> Selections
	let action: () -> Void
	@Environment(\.textTheme) var textTheme
	public init(
		value: String,
		title: String,
		@ViewBuilder selections: @escaping () -> Selections,
		action: @escaping () -> Void
	) {
		self.value = value
		self.title = title
		self.selections = selections
		self.action = action
	}
	public var body: some View {
		HStack(spacing: 16) {
			Menu {
				selections()
			} label: {
				Text(value)
				+
				Text("  ▼")
					.font(textTheme.labelSmall.font)
				
			}
			.padding(.vertical, 6)
			.overlay(alignment: .bottom) {
				Rectangle()
					.fill(Assets.Colors.focusColor)
					.frame(height: 1)
			}
			Text(title)
			Spacer()
		}
		.frame(height: 50)
		.foregroundStyle(Assets.Colors.bodyColor)
	}
}
