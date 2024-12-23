import AppUI
import Foundation
import InstaBlocks
import Kingfisher
import Shared
import SwiftUI
import ComposableArchitecture
import InstagramClient

@Reducer
public struct PostSmallReducer {
	public init() {}
	@ObservableState
	public struct State: Equatable, Identifiable {
		public private(set) var block: PostSmallBlock
		public private(set) var isOwner: Bool
		public fileprivate(set) var isLiked: Bool
		public init(
			block: PostSmallBlock,
			isOwner: Bool,
			isLiked: Bool
		) {
			self.block = block
			self.isOwner = isOwner
			self.isLiked = isLiked
		}
		public var id: String {
			block.id
		}
	}
	public enum Action: BindableAction {
		case binding(BindingAction<State>)
		case task
		case isLikedUpdate(Bool)
	}
	
	private enum Cancel: Hashable {
		case subscriptions
	}
	
	@Dependency(\.instagramClient) var instagramClient
	
	public var body: some ReducerOf<Self> {
		BindingReducer()
		Reduce { state, action in
			switch action {
			case .binding:
				return .none
			case .task:
				return .run { [postId = state.block.id] send in
					await subscriptions(send: send, postId: postId)
				}
				.cancellable(id: Cancel.subscriptions, cancelInFlight: true)
			case let .isLikedUpdate(isLiked):
				state.isLiked = isLiked
				return .none
			}
		}
	}
	
	private func subscriptions(send: Send<Action>, postId: String) async {
		async let isLikedStream: Void = {
			for await isLiked in await instagramClient.databaseClient.isLiked(postId, nil, true) {
				await send(.isLikedUpdate(isLiked))
			}
		}()
		_ = await isLikedStream
	}
}

public struct PostSmallView<ImageThumbnailView: View>: View {
	let store: StoreOf<PostSmallReducer>
	public let pinned: Bool
	@ViewBuilder public let imageThumbnailViewBuilder: ((_ url: String) -> ImageThumbnailView)?
	@Environment(\.colorScheme) var colorScheme
	@State private var blurHashImage: UIImage?
	public init(
		store: StoreOf<PostSmallReducer>,
		pinned: Bool,
		imageThumbnailViewBuilder: ((_ url: String) -> ImageThumbnailView)? = nil
	) {
		self.store = store
		self.pinned = pinned
		self.imageThumbnailViewBuilder = imageThumbnailViewBuilder
	}
	
	private var showPinned: Bool {
		pinned && store.block.media.count > 1 || pinned && !(store.block.media.count > 1)
	}
	
	private var showHasMultiplePhotos: Bool {
		!pinned && (store.block.media.count > 1)
	}
	
	private var showVideoIcon: Bool {
		!showPinned && (store.block.isReel)
	}

	public var body: some View {
		ZStack(alignment: .topTrailing) {
			thumbnailImage()
			if showPinned || showHasMultiplePhotos || showVideoIcon {
				if showVideoIcon {
					videoReelIcon()
				} else {
					pinnedOrMultiplePhotosIcon()
				}
			}
		}
	}
	
	@ViewBuilder
	private func thumbnailImage() -> some View {
		GeometryReader { proxy in
			if let imageThumbnailViewBuilder {
				imageThumbnailViewBuilder(store.block.firstMediaUrl!)
					.frame(width: proxy.size.width, height: proxy.size.height)
					.clipped()
			} else {
				KFImage.url(URL(string: store.block.firstMediaUrl!))
					.placeholder {
						if let blurHashImage {
							Image(uiImage: blurHashImage)
								.resizable()
						} else {
							Assets.Colors.customAdaptiveColor(
								colorScheme,
								light: Assets.Colors.gray,
								dark: Assets.Colors.darkGray
							)
						}
					}
					.fade(duration: 0.2)
					.resizable()
					.aspectRatio(contentMode: .fill)
					.frame(width: proxy.size.width, height: proxy.size.height)
					.clipped()
			}
		}
		.task {
			await store.send(.task).finish()
		}
	}
	
	@ViewBuilder
	private func videoReelIcon() -> some View {
		Assets.Icons.instagramReel
			.view(width: 22, height: 22, renderMode: .original)
			.foregroundStyle(.white)
			.shadow(color: .black.opacity(0.26), radius: 15, x: 2, y: 2)
			.padding(.top, 4)
			.padding(.trailing, 6)
	}
	
	@ViewBuilder
	private func pinnedOrMultiplePhotosIcon() -> some View {
		rotatedOrNotIcon()
			.padding(.top, 4)
			.padding(.trailing, 4)
	}
	
	@ViewBuilder
	private func rotatedOrNotIcon() -> some View {
		icon()
			.rotationEffect(showPinned ? .radians(0.75) : .radians(0))
	}
	
	@ViewBuilder
	private func icon() -> some View {
		(showPinned ? Image(systemName: "pin.fill") : Image(systemName: "square.2.layers.3d.fill"))
			.imageScale(.small)
			.frame(width: AppSize.iconSizeMedium, height: AppSize.iconSizeMedium)
			.foregroundStyle(.white)
	}
}
