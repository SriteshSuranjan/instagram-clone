import Foundation
import SwiftUI
import ComposableArchitecture
import AppUI
import InstagramBlocksUI
import Shared
import SnackbarMessagesClient
import MediaPickerFeature
import Supabase
import UploadTaskClient

@Reducer
public struct SignUpReducer {
	public init() {}
	@ObservableState
	public struct State: Equatable {
		var signUpForm = SignUpFormReducer.State()
		var status: SignUpSubmissionStatus = .idle
		@Presents var avatarPicker: MediaPickerReducer.State?
		var avatarImageData: Data?
		var signUpButtonDisabled: Bool {
			status.isLoading
		}
		public init() {}
		
		public enum SignUpSubmissionStatus: Equatable {
			case idle
			case inProgress
			case success
			case emailAlreadyRegistered
			case networkError
			case error
			
			var isSuccess: Bool {
				self == .success
			}
			var isLoading: Bool {
				self == .inProgress
			}
			var isEmailAlreadyRegistered: Bool {
				self == .emailAlreadyRegistered
			}
			var isNetworkError: Bool {
				self == .networkError
			}
			var isError: Bool {
				self == .error
			}
		}
	}
	public enum Action {
		case actionSignUp(email: String, fullName: String, userName: String, password: String)
		case delegate(Delegate)
		case onTapSignUpButton
		case resignFocus
		case signUpForm(SignUpFormReducer.Action)
		case signUpResponse(Result<Void, AuthenticationError>)
		case task
		case avatarPicker(PresentationAction<MediaPickerReducer.Action>)
		case onTapSelectAvatarButton
		
		public enum Delegate {
			case onTapSignInIntoAccountButton
		}
	}
	
	@Dependency(\.instagramClient.authClient) var authClient
	@Dependency(\.instagramClient.storageUploaderClient) var storageUploaderClient
	@Dependency(\.snackbarMessagesClient) var snackbarMessagesClient
	
	public var body: some ReducerOf<Self> {
		Scope(state: \.signUpForm, action: \.signUpForm) {
			SignUpFormReducer()
		}
		Reduce {
			state,
			action in
			switch action {
			case let .actionSignUp(email, fullName, userName, password):
				state.status = .inProgress
				return .run { [avatarImageData = state.avatarImageData] send in
					var avatarUrl: String?
					if let avatarImageData {
						let fileExtension = "png"
						@Dependency(\.date.now) var now
						let fileName = "\(now.ISO8601Format()).\(fileExtension)"
						try await storageUploaderClient.uploadBinaryWithData(
							"avatars",
							fileName,
							avatarImageData,
							FileOptions(
								cacheControl: "360000",
								contentType: "image/\(fileExtension)"
							)
						)
						avatarUrl = try await storageUploaderClient.createSignedUrl("avatars", fileName)
					}
					try await authClient.signUpWithPassword(password: password, fullName: fullName, username: userName, avatarUrl: avatarUrl, email: email, phone: nil, pushToken: nil)
//					await send(.signUpResponse(.success(())))
				} catch: {error, send in
					if let signUpError = error as? AuthenticationError {
						await send(.signUpResponse(.failure(signUpError)))
					} else {
						let signUpError = AuthenticationError.underlying(error: error, message: nil)
						await send(.signUpResponse(.failure(signUpError)))
					}
				}
			case .delegate:
				return .none
			case .onTapSignUpButton:
				return .run { [email = state.signUpForm.email, password = state.signUpForm.password, fullName = state.signUpForm.fullName, userName = state.signUpForm.userName] send in
					await send(.signUpForm(.emailDidEndEditing))
					await send(.signUpForm(.fullNameDidEndEditing))
					await send(.signUpForm(.userNameDidEndEditing))
					await send(.signUpForm(.passwordDidEndEditing))
					guard email.validated,
								password.validated,
								fullName.validated,
								userName.validated else {
						return
					}
					await send(.actionSignUp(email: email.value, fullName: fullName.value, userName: userName.value, password: password.value))
				}
			case .resignFocus:
				return .send(.signUpForm(.resignTextFieldFocus))
			case .signUpForm:
				return .none
			case let .signUpResponse(result):
				let signUpSubmissionStatus: State.SignUpSubmissionStatus
				switch result {
				case .success:
					signUpSubmissionStatus = .idle
					return .none
//					return .run { _ in
//						await snackbarMessagesClient.show(
//							SnackbarMessage.success(
//								title: "Sign up successfully",
//								backgroundColor: Assets.Colors.snackbarSuccessBackground
//							)
//						)
//					}
				case let .failure(error):
					if let errorCode = error.errorCode,
						 errorCode == 400  {
						signUpSubmissionStatus = .emailAlreadyRegistered
					} else {
						signUpSubmissionStatus = .error
					}
					state.status = signUpSubmissionStatus
					return .run { [errorDescription = error.errorDescription] _ in
						await snackbarMessagesClient.show(
							SnackbarMessage.error(
								title: "Sign up failed",
								description: errorDescription,
								backgroundColor: Assets.Colors.snackbarErrorBackground
							)
						)
					}
				}
			case let .avatarPicker(.presented(.delegate(.avatarNextAction(imageData)))):
				state.avatarImageData = imageData
				return .none
			case .avatarPicker:
				return .none
			case .task:
				return .none
			case .onTapSelectAvatarButton:
				state.avatarPicker = MediaPickerReducer.State(pickerConfiguration: MediaPickerView.Configuration(reels: false, showVideo: false), nextAction: .uploadAvatar)
				return .none
			}
		}
		.ifLet(\.$avatarPicker, action: \.avatarPicker) {
			MediaPickerReducer()
		}
	}
}

public struct SignUpView: View {
	@Bindable var store: StoreOf<SignUpReducer>
	@Environment(\.colorScheme) var colorScheme
	public init(store: StoreOf<SignUpReducer>) {
		self.store = store
	}
	public var body: some View {
		ZStack(alignment: .bottom) {
			ScrollView(showsIndicators: false) {
				VStack {
					logoView()
					Circle()
						.overlay {
							if let avatarImageData = store.avatarImageData {
								Image(uiImage: UIImage(data: avatarImageData)!)
									.resizable()
									.frame(width: 128, height: 128)
									.scaledToFit()
									.clipShape(.circle)
							} else {
								Assets.Images.profilePhoto
									.view(width: 128, height: 128, renderMode: .original, contentMode: .fit, tint: Assets.Colors.bodyColor)
							}
						}
						.overlay(alignment: .bottomTrailing) {
							Button {
								store.send(.onTapSelectAvatarButton)
							} label: {
								Circle()
									.fill(Assets.Colors.blue)
									.frame(width: 36, height: 36)
									.overlay {
										Image(systemName: "plus")
											.imageScale(.small)
									}
									.overlay {
										Circle()
											.stroke(Assets.Colors.customReversedAdaptiveColor(colorScheme), lineWidth: 2)
									}
									.contentShape(.circle)
							}
							.fadeEffect()
						}
						.frame(width: 128, height: 128)
					SignUpForm(store: store.scope(state: \.signUpForm, action: \.signUpForm))
						.padding(.bottom, AppSpacing.xlg)
					AuthButton(
						isLoading: store.status.isLoading,
						text: "Sign Up") {
							store.send(.onTapSignUpButton)
						}
						.disabled(store.signUpButtonDisabled)
				}
			}
			VStack {
				Spacer()
				SignInIntoAccountButton {
					store.send(.delegate(.onTapSignInIntoAccountButton))
				}
			}
			.frame(maxWidth: .infinity)
			.ignoresSafeArea(.keyboard)
		}
		.sheet(item: $store.scope(state: \.avatarPicker, action: \.avatarPicker)) { avatarPickStore in
			MediaPicker(store: avatarPickStore)
		}
		.scrollDismissesKeyboard(.automatic)
		.padding(.horizontal, AppSpacing.xlg)
		.toolbar(.hidden, for: .navigationBar)
		.task {
			await store.send(.task).finish()
		}
		.onTapGesture {
			store.send(.resignFocus)
		}
	}
	
	@ViewBuilder
	private func logoView() -> some View {
		AppLogoView(
			width: .infinity,
			height: 50,
			color: Assets.Colors.bodyColor,
			contentMode: .fit
		)
		.padding(.top, AppSpacing.xxxlg + AppSpacing.xlg)
	}
}

