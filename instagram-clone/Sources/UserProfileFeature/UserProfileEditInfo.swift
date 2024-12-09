import AppUI
import ComposableArchitecture
import Foundation
import SwiftUI
import UserClient

public struct UserProfileEditInfoDetail: Equatable {
	let editInfoType: UserProfileEditInfoType
	var value: String
	let maxBound: Int
}

public enum UserProfileEditInfoType: String, Hashable {
	case name = "Name"
	case username = "Username"
	case bio = "Bio"
	
	public var intro: String {
		switch self {
		case .name: return """
			Help people discover your account by using the name yor\'re known by: either your full name, nickname, or business name.
			
			You can only change your name twice within 14 days.
			"""
		case .username: return "You'll be able to change your username back to {username} for another 14 days"
		case .bio: return ""
		}
	}
}

@Reducer
public struct UserProfileEditInfoReducer {
	public init() {}
	@ObservableState
	public struct State: Equatable {
		var userId: String
		var editInfoDetail: UserProfileEditInfoDetail
		var text: String
		var focus: Field?
		var isRequesting: Bool = false
		var checkmarkButtonDisabled: Bool {
			text.count == 0 || text.count > editInfoDetail.maxBound
		}
		public init(userId: String, editInfoDetail: UserProfileEditInfoDetail, focus: Field? = .info) {
			self.userId = userId
			self.editInfoDetail = editInfoDetail
			self.text = editInfoDetail.value
			self.focus = focus
		}
		
		public enum Field: Hashable {
			case info
		}
	}
	
	@Dependency(\.userClient.databaseClient) var databaseClient

	public enum Action: BindableAction {
		case binding(BindingAction<State>)
		case textInputUpdated(String)
		case onTapCheckmarkButton
		case updateUserInfoFailed(Error)
		case delegate(Delegate)
		
		public enum Delegate {
			case updateUserInfoResult(Result<Void, Error>)
		}
	}

	public var body: some ReducerOf<Self> {
		BindingReducer()
		Reduce { state, action in
			switch action {
			case .binding:
				return .none
			case let .textInputUpdated(updatedText):
				guard updatedText.count <= state.editInfoDetail.maxBound else {
					return .none
				}
				state.text = updatedText
				return .none
			case .onTapCheckmarkButton:
				state.isRequesting = true
				return .run { [editType = state.editInfoDetail.editInfoType, text = state.text] send in
					var fullName: String?
					var username: String?
					var bio: String?
					switch editType {
					case .name:
						fullName = text
					case .username:
						username = text
					case .bio:
						bio = text
					}
					try await databaseClient.updateUser(fullName, username, nil, nil)
					await send(.delegate(.updateUserInfoResult(.success(()))))
				} catch: { error, send in
					await send(.updateUserInfoFailed(error))
				}
			case let .updateUserInfoFailed(error):
				state.isRequesting = false
				return .send(.delegate(.updateUserInfoResult(.failure(error))))
			case .delegate:
				return .none
			}
		}
	}
}

public struct UserProfileEditInfoView: View {
	@Bindable var store: StoreOf<UserProfileEditInfoReducer>
	@FocusState private var focus: UserProfileEditInfoReducer.State.Field?
	@Environment(\.textTheme) var textTheme
	@Environment(\.dismiss) var dismiss
	@State private var textInput: String
	public init(store: StoreOf<UserProfileEditInfoReducer>) {
		self.store = store
		self._textInput = State(wrappedValue: store.text)
	}

	public var body: some View {
		VStack(spacing: AppSpacing.xlg) {
			HStack {
				Button {
					dismiss()
				} label: {
					Image(systemName: "xmark")
						.imageScale(.large)
						.foregroundStyle(Assets.Colors.bodyColor)
						.contentShape(.rect)
				}
				.scaleEffect()
				
				Spacer()
				
				Text(store.editInfoDetail.editInfoType.rawValue)
					.font(textTheme.headlineSmall.font)
					.foregroundStyle(Assets.Colors.bodyColor)
				
				Spacer()
				
				if store.isRequesting {
					ProgressView()
						.tint(Assets.Colors.blue)
				} else {
					Button {
						store.send(.onTapCheckmarkButton)
					} label: {
						Image(systemName: "checkmark")
							.imageScale(.large)
							.foregroundStyle(store.checkmarkButtonDisabled ? Assets.Colors.gray.opacity(0.6) : Assets.Colors.blue)
							.contentShape(.rect)
					}
					.scaleEffect()
					.disabled(store.checkmarkButtonDisabled)
				}
			}
			.fontWeight(.bold)
			.frame(maxWidth: .infinity)
			
			VStack(alignment: .leading) {
				Text(store.editInfoDetail.editInfoType.rawValue)
					.font(textTheme.titleSmall.font)
					.foregroundStyle(Assets.Colors.gray)
				TextField(
					"",
					text: $textInput
				)
					.focused($focus, equals: .info)
					.font(textTheme.titleLarge.font)
					.textFieldStyle(.plain)
					.onChange(of: textInput) {
						textInput = String(textInput.prefix(store.editInfoDetail.maxBound))
						store.send(.textInputUpdated(textInput))
					}
				Divider()
					.frame(height: store.focus == .info ? 2 : 0.5)
					.background(Assets.Colors.bodyColor)
				Text("\(store.text.count)/\(store.editInfoDetail.maxBound)")
					.font(textTheme.bodyLarge.font)
					.foregroundStyle(Assets.Colors.gray)
					.frame(maxWidth: .infinity, alignment: .trailing)
			}
			.bind($store.focus, to: $focus)
			
			if !store.editInfoDetail.editInfoType.intro.isEmpty {
				Text(store.editInfoDetail.editInfoType.intro)
					.font(textTheme.labelSmall.font)
					.foregroundStyle(Assets.Colors.gray)
					.frame(maxWidth: .infinity, alignment: .leading)
			}
		}
		.padding(AppSpacing.lg)
		.frame(maxHeight: .infinity, alignment: .top)
		.onTapGesture {
			
		}
	}
}
