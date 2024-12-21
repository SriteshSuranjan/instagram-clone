import AppUI
import ComposableArchitecture
import InstagramBlocksUI
import MediaPickerFeature
import Shared
import SwiftUI
import InstagramClient
import SnackbarMessagesClient
import UploadTaskClient

@Reducer
public struct UserProfileEditReducer {
	public init() {}

	@Reducer(state: .equatable)
	public enum Destination {
		case mediaPicker(MediaPickerReducer)
		case editInfo(UserProfileEditInfoReducer)
	}

	@ObservableState
	public struct State: Equatable {
		var user: User
		var focus: UserProfileEditInfoType?
		var bio: String = ""
		@Presents var destination: Destination.State?
		public init(user: User) {
			self.user = user
		}
	}

	public enum Action: BindableAction {
		case binding(BindingAction<State>)
		case onTapEditing(UserProfileEditInfoType)
		case destination(PresentationAction<Destination.Action>)
		case updateUserAvatar
		case onTapChangeAvatar
		case task
		case userProfileUpdated(User)
	}

	@Dependency(\.instagramClient.databaseClient) var databaseClient
	@Dependency(\.snackbarMessagesClient) var snackbarMessagesClient
	@Dependency(\.uploadTaskClient.uploadTask) var uploadTask
	
	public var body: some ReducerOf<Self> {
		BindingReducer()
		Reduce {
			state,
			action in
			switch action {
			case .binding:
				return .none
			case let .onTapEditing(focus):
				state.focus = focus
				let (value, maxBound): (String, Int) = { switch focus {
				case .name: return (state.user.fullName ?? "", 40)
				case .username: return (state.user.username ?? "", 16)
				case .bio: return (state.bio, 16)
				}}()
				state.destination = .editInfo(UserProfileEditInfoReducer.State(userId: state.user.id, editInfoDetail: UserProfileEditInfoDetail(editInfoType: focus, value: value, maxBound: maxBound)))
				return .none
			case .destination(.presented(.mediaPicker(.delegate(.onTapCancelButton)))):
				state.destination = nil
				return .none
			case let .destination(.presented(.mediaPicker(.delegate(.avatarNextAction(imageData))))):
				return .run { [userId = state.user.id] send in
					await send(.updateUserAvatar)
					await uploadTask(
						.avatar(
							AvatarUploadTask(
								id: userId,
								avatarImageData: imageData
							)
						)
					)
				}
			case let .destination(.presented(.editInfo(.delegate(.updateUserInfoResult(result))))):
				switch result {
				case .success:
					state.destination = nil
					return .none
				case .failure:
					return .run { _ in
						await snackbarMessagesClient.show(.error(title: "Failed to update user profile", backgroundColor: Assets.Colors.snackbarErrorBackground))
					}
				}
			case .destination:
				return .none
			case .updateUserAvatar:
				state.destination = nil
				return .none
			case .task:
				return .run { [userId = state.user.id] send in
					await withTaskCancellation(id: "UserProfileSubscription", cancelInFlight: true) {
						for await updatedProfile in await databaseClient.profile(userId) {
							await send(.userProfileUpdated(updatedProfile))
						}
					}
				}
			case .onTapChangeAvatar:
				state.destination = .mediaPicker(MediaPickerReducer.State(pickerConfiguration: MediaPickerView.Configuration(reels: false, showVideo: false), nextAction: .uploadAvatar))
				return .none
			case let .userProfileUpdated(updatedUser):
				state.user = updatedUser
				return .none
			}
		}
		.ifLet(\.$destination, action: \.destination) {
			Destination.body
		}
	}
}

public struct UserProfileEditView: View {
	@Bindable var store: StoreOf<UserProfileEditReducer>
	@Environment(\.dismiss) var dismiss
	@Environment(\.textTheme) var textTheme
	public init(store: StoreOf<UserProfileEditReducer>) {
		self.store = store
	}

	public var body: some View {
		VStack {
			AppNavigationBar(title: store.user.displayFullName, backButtonAction: { dismiss() })
			ScrollView {
				VStack(spacing: AppSpacing.lg) {
					UserProfileAvatar(
						userId: store.user.id,
						avatarUrl: store.user.avatarUrl,
						onTap: { _ in
							store.send(.onTapChangeAvatar)
						}
					)
					Text("Change photo")
						.font(textTheme.bodyLarge.font)
						.foregroundStyle(Assets.Colors.blue)
					UserProfileEditTextField(
						title: UserProfileEditInfoType.name.rawValue,
						focused: store.focus == .name,
						text: store.user.displayFullName
					) {
						store.send(.onTapEditing(.name))
					}
					UserProfileEditTextField(
						title: UserProfileEditInfoType.username.rawValue,
						focused: store.focus == .username,
						text: store.user.username ?? ""
					) {
						store.send(.onTapEditing(.username))
					}
					UserProfileEditTextField(
						title: UserProfileEditInfoType.bio.rawValue,
						focused: store.focus == .bio,
						text: store.bio
					) {
						store.send(.onTapEditing(.bio))
					}
				}
			}
		}
		.sheet(item: $store.scope(state: \.destination?.mediaPicker, action: \.destination.mediaPicker)) { mediaPickerStore in
			MediaPicker(store: mediaPickerStore)
		}
		.sheet(item: $store.scope(state: \.destination?.editInfo, action: \.destination.editInfo)) { editInfoStore in
			UserProfileEditInfoView(store: editInfoStore)
				.presentationDetents([.large])
		}
		.padding(.horizontal, AppSpacing.lg)
		.toolbar(.hidden, for: .navigationBar)
		.task {
			await store.send(.task).finish()
		}
	}
}
