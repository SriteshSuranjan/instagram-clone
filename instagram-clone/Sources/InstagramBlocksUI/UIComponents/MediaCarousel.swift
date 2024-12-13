import AppUI
import BlurHashClient
import ComposableArchitecture
import Kingfisher
import Shared
import ShuffleIt
import SwiftUI

@Reducer
public struct MediaCarouselReducer {
	public init() {}
	@ObservableState
	public struct State: Equatable {
		var media: [MediaItem]
		var blurHashImages: [String: UIImage] = [:]
		public init(media: [MediaItem]) {
			self.media = media
		}
	}

	public enum Action: BindableAction {
		case binding(BindingAction<State>)
		case task
		case mediaHashImagesResponse([String: UIImage])
	}

	@Dependency(\.blurHashClient.decode) var blurHash

	public var body: some ReducerOf<Self> {
		BindingReducer()
		Reduce { state, action in
			switch action {
			case .binding:
				return .none
			case .task:
				return .run { [media = state.media] send in
					let blurHashImages = await withTaskGroup(of: (String, UIImage?).self) { group in
						for item in media {
							group.addTask {
								if let blurHashString = item.blurHash,
								   !blurHashString.isEmpty
								{
									return (item.id, await blurHash(blurHashString))
								}
								return (item.id, nil)
							}
						}

						var results: [String: UIImage] = [:]
						for await (id, blurHashImage) in group where blurHashImage != nil {
							results[id] = blurHashImage
						}
						return results
					}
					await send(.mediaHashImagesResponse(blurHashImages))
				}
			case let .mediaHashImagesResponse(blurHashImages):
				state.blurHashImages = blurHashImages
				return .none
			}
		}
	}
}

public struct MediaCarouselView: View {
	@Bindable var store: StoreOf<MediaCarouselReducer>
	@Environment(\.colorScheme) var colorScheme
	public init(store: StoreOf<MediaCarouselReducer>) {
		self.store = store
	}

	public var body: some View {
		ScrollView(.horizontal) {
			LazyHStack {
				ForEach(store.media) { media in
					KFImage.url(URL(string: media.previewUrl ?? ""))
						.placeholder {
							if let blurHashImage = store.blurHashImages[media.id] {
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
						.resizable()
						.fade(duration: 0.2)
						.scaledToFill()
						.containerRelativeFrame(.horizontal)
				}
			}
			.scrollTargetLayout()
		}
		.scrollIndicators(.hidden)
		.scrollTargetBehavior(.viewAligned)
		.scrollTargetLayout()
		.task {
			await store.send(.task).finish()
		}
	}
}

#Preview {
	MediaCarouselView(
		store: Store(
			initialState: MediaCarouselReducer.State(
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
			),
			reducer: { MediaCarouselReducer()
			}
		)
	)
}
