import Foundation
import SwiftUI
import AppUI
import Kingfisher

public struct PromoFloatingAction: View {
	var url: String
	var promoImageUrl: String
	var title: String
	var subTitle: String
	@Environment(\.textTheme) var textTheme
	public init(
		url: String,
		promoImageUrl: String,
		title: String,
		subTitle: String
	) {
		self.url = url
		self.promoImageUrl = promoImageUrl
		self.title = title
		self.subTitle = subTitle
		debugPrint(promoImageUrl)
	}
	private var displayUrl: String {
		guard let effectUrl = URL(string: url) else {
			return url
		}
		guard let host = effectUrl.host() else {
			return url
		}
		var hostSubs = host.split(separator: ".")
		hostSubs.removeFirst()
		return hostSubs.joined(separator: ".")
	}
	public var body: some View {
		HStack(spacing: AppSpacing.md) {
			KFImage.url(URL(string: promoImageUrl))
				.placeholder {
					Assets.Images.placeholder
						.view(width: 42, height: 42)
						.cornerRadius(2)
				}
				.fade(duration: 0.2)
				.resizable()
				.scaledToFill()
				.frame(width: 42, height: 42)
				.cornerRadius(2)
			VStack(alignment: .leading, spacing: AppSpacing.xs) {
				Text(title)
					.font(textTheme.bodyLarge.font)
					.bold()
				HStack(alignment: .firstTextBaseline, spacing: AppSpacing.xs) {
					Text(subTitle)
						.font(textTheme.bodySmall.font)
						.foregroundStyle(Assets.Colors.darkGray)
					Text(displayUrl)
						.underline()
						.font(textTheme.bodyLarge.font)
						.bold()
				}
			}
			.foregroundStyle(Assets.Colors.white)
			Spacer()
			Image(systemName: "arrow.turn.down.right")
				.imageScale(.large)
				.bold()
				.foregroundStyle(Assets.Colors.white)
		}
		.frame(maxWidth: .infinity)
		.padding(.horizontal, AppSpacing.md)
		.padding(.vertical, AppSpacing.sm)
		.background(
			Assets.Colors.blue.cornerRadius(4)
		)
		
	}
}

#Preview {
	PromoFloatingAction(
		url: "www.bing.com",
		promoImageUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a5/Instagram_icon.png/600px-Instagram_icon.png",
		title: "Learn more",
		subTitle: "www.bing.com"
	)
}
