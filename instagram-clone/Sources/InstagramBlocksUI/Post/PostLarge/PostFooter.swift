import AppUI
import ComposableArchitecture
import Foundation
import InstaBlocks
import Kingfisher
import Shared
import SwiftUI

@Reducer
public struct PostFooterReducer {
	public init() {}
	@ObservableState
	public struct State: Equatable {
		var block: InstaBlockWrapper
		var isLiked: Bool
		var likesCount: Int
		var commentsCount: Int
		var mediaUrls: [String]
		var likersInFollowings: [User]
		@Shared var currentMediaIndex: Int
		public init(
			block: InstaBlockWrapper,
			isLiked: Bool,
			likesCount: Int,
			commentsCount: Int,
			mediaUrls: [String],
			likersInFollowings: [User],
			currentMediaIndex: Shared<Int>
		) {
			self.block = block
			self.isLiked = isLiked
			self.likesCount = likesCount
			self.commentsCount = commentsCount
			self.mediaUrls = mediaUrls
			self.likersInFollowings = likersInFollowings
			self._currentMediaIndex = currentMediaIndex
		}
		
		var firstLikerInFollowings: User? {
			likersInFollowings.first
		}

		var suffixLikersCount: Int {
			likersInFollowings.count - 1
		}
	}

	public enum Action: BindableAction {
		case binding(BindingAction<State>)
		case onTapLikeButton
	}

	public var body: some ReducerOf<Self> {
		BindingReducer()
		Reduce { _, action in
			switch action {
			case .binding:
				return .none
			case .onTapLikeButton:
				return .none
			}
		}
	}
}

public struct PostFooterView: View {
	@Bindable var store: StoreOf<PostFooterReducer>
	@Environment(\.colorScheme) var colorScheme
	@Environment(\.textTheme) var textTheme
	public init(store: StoreOf<PostFooterReducer>) {
		self.store = store
	}

	public var body: some View {
		VStack(alignment: .leading, spacing: AppSpacing.sm) {
			if store.block.isSponsored {
				Color.blue
					.frame(maxWidth: .infinity)
					.frame(height: 30)
					.padding(.bottom, AppSpacing.sm)
			}
			
			HStack(spacing: AppSpacing.lg) {
				likeButton()
				commentButton()
				shareButton()
				Spacer()
				bookmarkButton()
			}
			.overlay(alignment: .center) {
				if store.mediaUrls.count > 1 {
					DotIndicator(totalCount: store.mediaUrls.count, currentIndex: $store.currentMediaIndex)
				}
			}
			.padding(.vertical, store.block.isSponsored ? 0 : AppSpacing.sm)
			.padding(.horizontal, AppSpacing.sm)
			
			likers()
		}
	}
	
	private var likesAvatarRadius: CGFloat {
		switch store.likersInFollowings.count {
		case 1: return 14
		case 2: return 22
		default: return 30
		}
	}
	
	@ViewBuilder
	private func likeButton() -> some View {
		Button {} label: {
			Image(systemName: store.isLiked ? "heart.fill" : "heart")
				.imageScale(.large)
				.foregroundStyle(store.isLiked ? Assets.Colors.red : Assets.Colors.bodyColor)
				.bold()
				.contentShape(.rect)
		}
		.scaleEffect(config: ButtonAnimationConfig(scale: .xs))
		.frame(width: AppSize.iconSize, height: AppSize.iconSize)
	}
	
	@ViewBuilder
	private func commentButton() -> some View {
		Button {} label: {
			Image(systemName: "message")
				.scaleEffect(x: -1, y: 1)
				.imageScale(.large)
				.foregroundStyle(Assets.Colors.bodyColor)
				.bold()
				.contentShape(.rect)
		}
		.scaleEffect(config: ButtonAnimationConfig(scale: .xs))
		.frame(width: AppSize.iconSize, height: AppSize.iconSize)
	}
	
	@ViewBuilder
	private func shareButton() -> some View {
		Button {} label: {
			Image(systemName: "arrowshape.turn.up.right")
				.imageScale(.large)
				.foregroundStyle(Assets.Colors.bodyColor)
				.bold()
				.contentShape(.rect)
		}
		.scaleEffect(config: ButtonAnimationConfig(scale: .xs))
		.frame(width: AppSize.iconSize, height: AppSize.iconSize)
	}
	
	@ViewBuilder
	private func bookmarkButton() -> some View {
		Button {} label: {
			Image(systemName: "bookmark")
				.imageScale(.large)
				.foregroundStyle(Assets.Colors.bodyColor)
				.bold()
				.contentShape(.rect)
		}
		.scaleEffect(config: ButtonAnimationConfig(scale: .xs))
		.frame(width: AppSize.iconSize, height: AppSize.iconSize)
	}
	
	@ViewBuilder
	private func likers() -> some View {
		if store.likesCount > 0 {
			HStack(spacing: AppSpacing.sm) {
				if store.likersInFollowings.count > 0 {
					HStack(spacing: 0) {
						ForEach(Array(store.likersInFollowings.enumerated()), id: \.element.id) { index, user in
							KFImage.url(URL(string: user.avatarUrl ?? ""))
								.placeholder {
									Color.gray
										.frame(width: likesAvatarRadius, height: likesAvatarRadius)
										.clipShape(.circle)
								}
								.resizable()
								.fade(duration: 0.2)
								.scaledToFill()
								.clipShape(.circle)
								.frame(width: likesAvatarRadius, height: likesAvatarRadius)
								.offset(x: CGFloat(index) * (-likesAvatarRadius / 2))
								.zIndex(Double(index))
						}
					}
				}
				Group {
					Text("\(store.likesCount) ")
					+ Text("Likes")
						.bold()
					
					if let firstLiker = store.firstLikerInFollowings {
						Text("\(firstLiker.displayFullName)")
							.bold()
					}
					if store.suffixLikersCount > 0 {
						Text("and")
						+
						Text(" \(store.suffixLikersCount) others")
							.bold()
					}
					
				}
				.font(textTheme.titleMedium.font)
				.foregroundStyle(Assets.Colors.bodyColor)
			}
			.padding(.horizontal, AppSpacing.sm)
			.padding(.vertical, AppSpacing.sm)
			.transition(.move(edge: .top))
		}
	}
}

#Preview {
	PostFooterView(
		store: Store(
			initialState: PostFooterReducer.State(
				block: .postLarge(
					PostLargeBlock(
						id: "aaf841ab-e823-4187-8a07-f9bfdc98e0a4",
						author: PostAuthor(),
						createdAt: Date.now,
						caption: "This is caption",
						media: [
							.image(ImageMedia(id: "123445", url: "https://uuhkqhxfbjovbighyxab.supabase.co/storage/v1/object/public/posts/079b8318-51bc-4b50-80ac-fbf42361124d/image_0", blurHash: "LVC?N0af9+bJ0ga{-ijX=@e-N2az")),
							.video(
								VideoMedia(
									id: "d7784ce7-49ca-461a-ab52-14017f9be458",
									url: "https://uuhkqhxfbjovbighyxab.supabase.co/storage/v1/object/public/posts/00c8e0ea-d59e-45ee-b0d6-5034ff2d61e2/video_0",
									blurHash: "LQKT[CR*?v-p~Vx^V@jb?aInRPWX",
									firstFrameUrl: "https://uuhkqhxfbjovbighyxab.supabase.co/storage/v1/object/public/posts/00c8e0ea-d59e-45ee-b0d6-5034ff2d61e2/video_first_frame_0)"
								)
							)
						]
					)
				),
				isLiked: true,
				likesCount: 10,
				commentsCount: 10,
				mediaUrls: ["https://uuhkqhxfbjovbighyxab.supabase.co/storage/v1/object/public/posts/079b8318-51bc-4b50-80ac-fbf42361124d/image_0"],
				likersInFollowings: [
					User(
						id: "11",
						email: nil,
						username: nil,
						fullName: nil,
						avatarUrl: "https://uuhkqhxfbjovbighyxab.supabase.co/storage/v1/object/sign/avatars/2024-12-09T13:17:05Z.png?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1cmwiOiJhdmF0YXJzLzIwMjQtMTItMDlUMTM6MTc6MDVaLnBuZyIsImlhdCI6MTczMzc1MDIzMCwiZXhwIjoxNzMzNzUwMjkwfQ.dQPRTi88KIssjIyJgennCbkQOwjJePionj-Fza8Z4K8",
						pushToken: nil,
						isNewUser: false
					),
					User(id: "22", avatarUrl: "https://uuhkqhxfbjovbighyxab.supabase.co/storage/v1/object/sign/avatars/2024-12-09T15:44:00.078471.jpg?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1cmwiOiJhdmF0YXJzLzIwMjQtMTItMDlUMTU6NDQ6MDAuMDc4NDcxLmpwZyIsImlhdCI6MTczMzczMDI0MywiZXhwIjoyMDQ5MDkwMjQzfQ.hukTLDivWUBKKEpukDmJ1H1qcaa87pgZnmLqRmnrvI0")
				],
				currentMediaIndex: Shared(0)
			),
			reducer: { PostFooterReducer()
			}
		)
	)
}
