import AppUI
import Foundation
import InstaBlocks
import InstagramBlocksUI
import Kingfisher
import Shared
import SwiftUI
import ComposableArchitecture

public struct PostPreview: View {
	public let block: InstaBlockWrapper
	@Environment(\.colorScheme) var colorScheme
	@Environment(\.textTheme) var textTheme
	public init(block: InstaBlockWrapper) {
		self.block = block
	}

	public var body: some View {
		ZStack(alignment: .top) {
//			KFImage.url(URL(string: block.block.firstMediaUrl!))
//				.placeholder {
//					Assets.Colors.customAdaptiveColor(
//						colorScheme,
//						light: Assets.Colors.gray,
//						dark: Assets.Colors.darkGray
//					)
//				}
//				.fade(duration: 0.2)
//				.resizable()
//				.scaledToFill()
//						.blurScroll(10, blurHeight: 0.1, blurPosition: .top, enableScroll: false)
//						.clipped()
			
			MediaCarouselView(
				store: Store(
					initialState: MediaCarouselReducer.State(media: [block.media!.first!], currentMediaIndex: Shared(0), videoMuted: Shared(false)),
					reducer: { MediaCarouselReducer() }
				)
			)
			.aspectRatio(1 / 1.2, contentMode: .fill)
			.blurScroll(4, blurHeight: 0.1, blurPosition: .top, enableScroll: false)
//			VStack {
				HStack {
					UserProfileAvatar(
						userId: block.author.id,
						avatarUrl: block.author.avatarUrl,
						radius: 24
					)
					Text(block.author.username)
						.font(textTheme.titleLarge.font)
						.fontWeight(.bold)
						.foregroundStyle(Assets.Colors.customReversedAdaptiveColor(colorScheme))
					Spacer()
				}
				.padding()
				
//				FlexibleRowLayout {
//					Button {
//					} label: {
//						Image(systemName: "heart")
//							.imageScale(.large)
//							.frame(maxWidth: .infinity)
//							.flex(1)
//							.contentShape(.rect)
//					}
//					.fadeEffect()
//					Image(systemName: "message")
//						.imageScale(.large)
//						.frame(maxWidth: .infinity)
//						.flex(1)
//					Image(systemName: "location")
//						.imageScale(.large)
//						.frame(maxWidth: .infinity)
//						.flex(1)
//					Image(systemName: "ellipsis")
//						.imageScale(.large)
//						.frame(maxWidth: .infinity)
//						.rotationEffect(.degrees(90))
//						.offset(y: 8)
//						.flex(1)
//				}
//				.fontWeight(.semibold)
//				.padding()
//				.background(
//					Assets.Colors.customReversedAdaptiveColor(
//						colorScheme,
//						light: Assets.Colors.brightGray,
//						dark: Assets.Colors.emphasizeDarkGrey
//					)
//					.opacity(0.6)
//					.clipShape(.rect(cornerRadii: RectangleCornerRadii(topLeading: 0, bottomLeading: 16, bottomTrailing: 16, topTrailing: 0)))
//				)
//			}
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity) // 确保 ZStack 填充所有可用空间
				.clipShape(RoundedRectangle(cornerRadius: 16))
	}

	private func thumbnailWidth(from size: CGFloat) -> CGFloat {
		(size - 2 * AppSpacing.md).rounded()
	}
}

#Preview {
	PostPreview(
		block: .postLarge(
			PostLargeBlock(
				id: "413d5e4a-e558-4c8a-8974-437e755eea3f",
				author: PostAuthor(),
				createdAt: Date(),
				caption: "Caption",
				media: [.memoryImage(
					MemoryImageMedia(
						id: "memoryImageMedia",
						url: "https://uuhkqhxfbjovbighyxab.supabase.co/storage/v1/object/public/posts/6ba7399b-e01d-407b-9bcc-4d89129f3d92/image_0",
						previewData: nil,
						blurHash: nil
					)
				)]
			)
		)
	)
}
