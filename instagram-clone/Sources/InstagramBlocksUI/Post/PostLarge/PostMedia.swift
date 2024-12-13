import Foundation
import SwiftUI
import ComposableArchitecture
import InstaBlocks
import AppUI
import Shared

/*final List<Media> media;
 final int? postIndex;
 final VoidCallback? likePost;
 final bool isLiked;
 final ValueSetter<int>? onPageChanged;
 final VideoPlayerBuilder? videoPlayerBuilder;
 final MediaCarouselSettings? mediaCarouselSettings;
 final bool withLikeOverlay;
 final bool withInViewNotifier;
 final bool autoHideCurrentIndex;*/

@Reducer
public struct PostMediaReducer {
	public init() {}
	@ObservableState
	public struct State: Equatable {
		var media: [MediaItem]
		var postIndex: Int?
		var isLiked: Bool
		var withLikeOverlay: Bool
		var autoHideCurrentIndex: Bool
		var carousel: MediaCarouselReducer.State
		public init(
			media: [MediaItem],
			postIndex: Int? = nil,
			isLiked: Bool,
			withLikeOverlay: Bool = false,
			autoHideCurrentIndex: Bool = true
		) {
			self.media = media
			self.postIndex = postIndex
			self.isLiked = isLiked
			self.withLikeOverlay = withLikeOverlay
			self.autoHideCurrentIndex = autoHideCurrentIndex
			self.carousel = MediaCarouselReducer.State(media: media)
		}
	}
	public enum Action: BindableAction {
		case binding(BindingAction<State>)
		case carousel(MediaCarouselReducer.Action)
	}
	public var body: some ReducerOf<Self> {
		BindingReducer()
		Scope(state: \.carousel, action: \.carousel) {
			MediaCarouselReducer()
		}
		Reduce { state, action in
			switch action {
			case .binding:
				return .none
			case .carousel:
				return .none
			}
		}
	}
}

public struct PostMediaView: View {
	@Bindable var store: StoreOf<PostMediaReducer>
	public init(store: StoreOf<PostMediaReducer>) {
		self.store = store
	}
	public var body: some View {
		MediaCarouselView(store: store.scope(state: \.carousel, action: \.carousel))
	}
}
