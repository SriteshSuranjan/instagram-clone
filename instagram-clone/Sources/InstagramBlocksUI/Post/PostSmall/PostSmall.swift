import AppUI
import Foundation
import InstaBlocks
import Kingfisher
import Shared
import SwiftUI

public struct PostSmall<ImageThumbnailView: View>: View {
	public let mediaUrl: String
	public let blurHash: String?
	public let isReel: Bool?
	public let pinned: Bool
	public let multiMedia: Bool
	@ViewBuilder public let imageThumbnailViewBuilder: ((_ url: String) -> ImageThumbnailView)?
	
	@Environment(\.colorScheme) var colorScheme
	@State private var blurHashImage: UIImage?
	public init(
		mediaUrl: String,
		blurHash: String?,
		isReel: Bool? = nil,
		pinned: Bool,
		multiMedia: Bool,
		imageThumbnailViewBuilder: ((_ url: String) -> ImageThumbnailView)? = nil
	) {
		self.mediaUrl = mediaUrl
		self.blurHash = blurHash
		self.isReel = isReel
		self.pinned = pinned
		self.multiMedia = multiMedia
		self.imageThumbnailViewBuilder = imageThumbnailViewBuilder
	}
	
	private var showPinned: Bool {
		pinned && multiMedia || pinned && !multiMedia
	}
	
	private var showHasMultiplePhotos: Bool {
		!pinned && multiMedia
	}
	
	private var showVideoIcon: Bool {
		!showPinned && (isReel ?? false)
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
				imageThumbnailViewBuilder(mediaUrl)
					.frame(width: proxy.size.width, height: proxy.size.height)
					.clipped()
			} else {
				KFImage.url(URL(string: mediaUrl))
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
