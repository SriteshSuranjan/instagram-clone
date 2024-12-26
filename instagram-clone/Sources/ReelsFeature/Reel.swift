import AppUI
import AVFoundation
import ComposableArchitecture
import Foundation
import InstaBlocks
import InstagramBlocksUI
import InstagramClient
import Kingfisher
import Shared
import SwiftUI
import VideoPlayer

@Reducer
public struct ReelReducer {
	public init() {}
	@ObservableState
	public struct State: Equatable, Identifiable {
		var authorizedId: String
		public private(set) var block: PostReelBlock
		public private(set) var withSound: Bool
		public fileprivate(set) var play: Bool
		var likesCount: Int = 0
		var commentsCount: Int = 0
		var isLike: Bool = false
		var isFollowed: Bool?
		public init(
			authorizedId: String,
			block: PostReelBlock,
			withSound: Bool,
			play: Bool
		) {
			self.authorizedId = authorizedId
			self.block = block
			self.withSound = withSound
			self.play = play
		}

		public var id: String {
			block.id
		}
	}

	public enum Action: BindableAction {
		case binding(BindingAction<State>)
		case likesCountUpdated(Int)
		case commentsCountUpdated(Int)
		case isLikedUpdated(Bool)
		case postAuthorFollowingStatusDidUpdated(Bool)
		case onTapLikeButton
		case onTapFollowButton
		case task
	}

	@Dependency(\.continuousClock) var clock
	@Dependency(\.instagramClient.databaseClient) var databaseClient

	private enum Cancel {
		case subscriptions
		case likeRequest
		case followRequest
	}

	public var body: some ReducerOf<Self> {
		BindingReducer()
		Reduce { state, action in
			switch action {
			case .binding:
				return .none
			case .task:
				return .run { [block = state.block, authorizedId = state.authorizedId] send in
					await subscriptions(send: send, post: block, authorizedId: authorizedId)
				}
				.cancellable(id: Cancel.subscriptions, cancelInFlight: true)
			case let .likesCountUpdated(likesCount):
				state.likesCount = likesCount
				return .none
			case let .commentsCountUpdated(commentsCount):
				state.commentsCount = commentsCount
				return .none
			case let .isLikedUpdated(isLike):
				state.isLike = isLike
				return .none
			case .onTapLikeButton:
				return .run { [postId = state.block.id] _ in
					try await databaseClient.likePost(postId, true)
				}
				.cancellable(id: Cancel.likeRequest, cancelInFlight: true)
			case let .postAuthorFollowingStatusDidUpdated(followed):
				state.isFollowed = followed
				return .none
			case .onTapFollowButton:
				return .run { [postAuthorId = state.block.author.id, profileUserId = state.authorizedId] _ in
					try await databaseClient.follow(postAuthorId, profileUserId)
				}
				.cancellable(id: Cancel.followRequest, cancelInFlight: true)
			}
		}
		._printChanges()
	}
	
	private func subscriptions(
		send: Send<Action>,
		post: any PostBlock,
		authorizedId: String
	) async {
		async let likesCount: Void = {
			for await likesCount in await databaseClient.likesOfPost(post.id, true) {
				await send(.likesCountUpdated(likesCount))
			}
		}()
		async let commentsCount: Void = {
			for await commentsCount in await databaseClient.postCommentsCount(post.id) {
				await send(.commentsCountUpdated(commentsCount))
			}
		}()
		async let isLiked: Void = {
			for await isLiked in await databaseClient.isLiked(post.id, nil, true) {
				await send(.isLikedUpdated(isLiked))
			}
		}()
		
		async let followingStatus: Void = {
			if authorizedId != post.author.id {
				for await isFollowed in await databaseClient.postAuthorFollowingStatus(post.author.id, authorizedId) {
					await send(.postAuthorFollowingStatusDidUpdated(isFollowed))
				}
			}
		}()
		
		_ = await (likesCount, commentsCount, isLiked, followingStatus)
	}
}

public struct ReelView: View {
	@Bindable var store: StoreOf<ReelReducer>
	@Environment(\.colorScheme) var colorScheme
	@Environment(\.textTheme) var textTheme
	@Binding var play: Bool
	@State private var time: CMTime = .zero
	@State private var totalDuration: CGFloat = 0
	@State private var authIconLoaded = false
	public init(store: StoreOf<ReelReducer>, play: Binding<Bool>) {
		self.store = store
		self._play = play
	}

	private var playProgress: Binding<CGFloat> {
		Binding(
			get: {
				if totalDuration == 0 {
					return 0
				}
				return time.seconds / totalDuration
			},
			set: { newProgress in
				if totalDuration > 0 {
					let upBoundDuration = min(self.totalDuration, self.totalDuration * newProgress)
					let boundedDuration = max(0, upBoundDuration)
					time = CMTimeMakeWithSeconds(boundedDuration, preferredTimescale: self.time.timescale)
				}
			}
		)
	}

	public var body: some View {
		GeometryReader { proxy in
			Group {
				if !play && totalDuration == 0 {
					if let previewData = store.block.firstMedia?.previewData {
						Image(uiImage: UIImage(data: previewData)!)
							.resizable()
							.scaledToFit()
							.frame(width: proxy.size.width, height: proxy.size.height)
					} else {
						KFImage.url(URL(string: store.block.firstMedia!.previewUrl ?? ""))
							.placeholder {
								Assets.Colors.customAdaptiveColor(
									colorScheme,
									light: Assets.Colors.brightGray,
									dark: Assets.Colors.gray
								)
								.overlay {
									ProgressView()
								}
							}
							.resizable()
							.fade(duration: 0.2)
							.scaledToFit()
							.frame(width: proxy.size.width, height: proxy.size.height)
					}
					
				} else {
					VideoPlayer(
						url: URL(string: store.block.firstMedia!.url)!,
						play: $play,
						time: $time
					)
					.autoReplay(true)
					.mute(!store.withSound)
					.onBufferChanged { _ in
//						debugPrint("Reel: bufferChanged \(progress)")
					}
					.onStateChanged { state in
						switch state {
						case .loading:
							debugPrint("Reel: loading")
						case let .playing(totalDuration):
							debugPrint("Reel: playing \(totalDuration)")
							self.totalDuration = totalDuration
						case let .paused(playProgress, bufferProgress):
							debugPrint("Reel: paused \(playProgress) \(bufferProgress)")
						case let .error(nSError):
							debugPrint("Reel: error \(nSError.localizedDescription)")
						}
					}
					.scaledToFit()
				}
			}
			.frame(width: proxy.size.width, height: proxy.size.height)
			.onTapGesture {
				play.toggle()
			}
		}
		.frame(maxHeight: .infinity)
		.safeAreaInset(edge: .bottom) {
			SmoothProgressBar(
				color: Assets.Colors.brightGray,
				backgroundColor: Assets.Colors.dark,
				height: 8,
				progress: playProgress
			)
			.padding(.bottom, 80)
		}
		.overlay(alignment: .bottomTrailing) {
			iconsGroup()
		}
		.overlay(alignment: .bottomLeading) {
			postInfosGroup()
		}
		.background(Assets.Colors.black)
		.task {
			await store.send(.task).finish()
		}
	}
	
	@ViewBuilder
	private func postInfosGroup() -> some View {
		VStack {
			postAuthorInfo()
			captionText()
			postSoundInfo()
		}
		.padding(.leading)
		.padding(.bottom, AppSpacing.xxxlg + AppSpacing.xxlg)
	}
	
	@ViewBuilder
	private func captionText() -> some View {
		if !store.block.caption.isEmpty {
			Text(store.block.caption)
				.font(textTheme.titleSmall.font)
				.foregroundStyle(Assets.Colors.white)
				.frame(maxWidth: .infinity, alignment: .leading)
				.padding(.vertical, AppSpacing.md)
		}
	}
	
	@ViewBuilder
	private func postSoundInfo() -> some View {
		HStack {
			originalAuthorLabel()
			postPartitipantLabel()
			Spacer()
		}
	}
	
	@ViewBuilder
	private func originalAuthorLabel() -> some View {
		Button {
			
		} label: {
			HStack(spacing: AppSpacing.sm) {
				Image(systemName: "music.note")
					.imageScale(.medium)
					.bold()
				MarqueeText("\(store.block.author.username) • Original audio", startDelay: 1.0)
			}
			.foregroundStyle(Assets.Colors.white)
			.frame(height: 36)
			.frame(maxWidth: 180)
			.padding(.horizontal, AppSpacing.sm)
			.background(
				Assets.Colors.customReversedAdaptiveColor(
					colorScheme,
					light: Assets.Colors.lightDark,
					dark: Assets.Colors.dark
				)
				
			)
			.clipShape(.capsule)
			.overlay {
				Capsule()
					.stroke(Assets.Colors.borderOutline, lineWidth: 1.5)
			}
		}
	}
	
	@ViewBuilder
	private func postPartitipantLabel() -> some View {
		HStack(spacing: AppSpacing.sm) {
			Image(systemName: "person.fill")
				.imageScale(.medium)
				.bold()
			MarqueeText("\(store.block.author.username)", startDelay: 1.0)
		}
		.foregroundStyle(Assets.Colors.white)
		.frame(height: 32)
		.frame(maxWidth: 80)
		.padding(.horizontal, AppSpacing.sm)
		.background(
			Assets.Colors.customReversedAdaptiveColor(
				colorScheme,
				light: Assets.Colors.lightDark,
				dark: Assets.Colors.dark
			)
		)
		.clipShape(.capsule)
		.overlay {
			Capsule()
				.stroke(Assets.Colors.borderOutline, lineWidth: 1.5)
		}
	}
	
	@ViewBuilder
	private func postAuthorInfo() -> some View {
		HStack {
			KFImage.url(URL(string: store.block.author.avatarUrl))
				.placeholder {
					Assets.Images.profilePhoto
						.view(width: 42, height: 42, renderMode: .template)
						.foregroundStyle(Assets.Colors.white)
				}
				.resizable()
				.fade(duration: 0.2)
				.scaledToFit()
				.frame(width: 42, height: 42)
				.clipShape(.circle)
			Text(store.block.author.username)
				.font(textTheme.titleMedium.font)
				.foregroundStyle(Assets.Colors.white)
				.bold()
				.layoutPriority(1)
			if let isFollowed = store.isFollowed {
				Button {
					store.send(.onTapFollowButton)
				} label: {
					Text(isFollowed ? "Following" : "Follow")
						.font(textTheme.bodyLarge.font)
						.bold()
						.padding(.horizontal, AppSpacing.md)
						.padding(.vertical, AppSpacing.xs)
						.foregroundStyle(Assets.Colors.white)
						.overlay {
							RoundedRectangle(cornerRadius: 8)
								.stroke(Assets.Colors.white, lineWidth: 1)
						}
						.contentShape(.rect)
				}
				.fadeEffect()
			}
			Spacer()
		}
	}
	
	@ViewBuilder
	private func iconsGroup() -> some View {
		VStack(spacing: AppSpacing.lg) {
			likeIcon()
			commentsIcon()
			shareIcon()
			optionsIcon()
			authorIcon()
		}
		.padding(.trailing)
		.padding(.bottom, AppSpacing.xxxlg + AppSpacing.xxlg)
	}
	
	@ViewBuilder private func likeIcon() -> some View {
		postIcon(
			with: store.block,
			systemName: store.isLike ? "heart.fill" : "heart",
			iconForegroundColor: store.isLike ? Assets.Colors.red : Assets.Colors.white,
			title: "\(store.likesCount)"
		) {
			store.send(.onTapLikeButton)
		}
	}

	@ViewBuilder
	private func commentsIcon() -> some View {
		postIcon(
			with: store.block,
			systemName: "message",
			title: "\(store.commentsCount)"
		) {
			
		}
//		Button {} label: {
//			VStack(spacing: 2) {
//				Assets.Icons.chatCircle
//					.view(width: AppSize.iconSize, height: AppSize.iconSize)
//				Text("\(store.commentsCount)")
//					.font(textTheme.bodySmall.font)
//					.contentTransition(.numericText())
//			}
//			.bold()
//			.foregroundStyle(Assets.Colors.white)
//			.contentShape(.rect)
//		}
//		.fadeEffect()
	}
	
	@ViewBuilder
	private func optionsIcon() -> some View {
		postIcon(with: store.block, systemName: "ellipsis", title: "") {}
			.rotationEffect(.degrees(90))
	}
	
	@ViewBuilder
	private func shareIcon() -> some View {
		postIcon(
			with: store.block,
			systemName: "location",
			title: ""
		) {}
	}
	
	@ViewBuilder
	private func authorIcon() -> some View {
		KFImage.url(URL(string: store.block.author.avatarUrl))
			.placeholder {
				Assets.Images.profilePhoto
					.view(width: AppSize.iconSize, height: AppSize.iconSize, renderMode: .template)
					.foregroundStyle(Assets.Colors.white)
			}
			.onSuccess { _ in
				authIconLoaded = true
			}
			.resizable()
			.scaledToFit()
			.frame(width: AppSize.iconSize, height: AppSize.iconSize)
			.overlay {
				if authIconLoaded {
					RoundedRectangle(cornerRadius: 4)
						.stroke(Assets.Colors.white, lineWidth: 3)
				}
			}
	}
	
	@ViewBuilder private func postIcon(
		with block: PostReelBlock,
		systemName: String,
		iconForegroundColor: Color = Assets.Colors.white,
		title: String,
		action: @escaping () -> Void
	) -> some View {
		Button {
			action()
		} label: {
			VStack(spacing: AppSpacing.xs) {
				Image(systemName: systemName)
					.imageScale(.large)
					.frame(width: AppSize.iconSizeBig, height: AppSize.iconSizeBig)
					.foregroundStyle(iconForegroundColor)
				if !title.isEmpty {
					Text(title)
						.font(textTheme.bodySmall.font)
						.contentTransition(.numericText())
						.foregroundStyle(Assets.Colors.white)
				}
			}
			.bold()
			.contentShape(.rect)
		}
		.fadeEffect()
	}
}
