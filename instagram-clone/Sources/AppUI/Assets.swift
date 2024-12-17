import RswiftResources
import SwiftUI
import Lottie

@MainActor
public enum Assets {
	@MainActor
	public struct Icons {
		public static let google = AppImageResource(imageResource: R.image.google)
		public static let github = AppImageResource(imageResource: R.image.github)
		public static let addButton = AppImageResource(imageResource: R.image.addButton)
		public static let chatCircle = AppImageResource(imageResource: R.image.chat_circle)
		public static let check = AppImageResource(imageResource: R.image.check)
		public static let instagramReel = AppImageResource(imageResource: R.image.instagramReel)
		public static let search = AppImageResource(imageResource: R.image.search)
		public static let setting = AppImageResource(imageResource: R.image.setting)
		public static let trash = AppImageResource(imageResource: R.image.trash)
		public static let user = AppImageResource(imageResource: R.image.user)
		public static let verifiedUser = AppImageResource(imageResource: R.image.verified_user)
	}

	@MainActor
	public struct Images {
		public static let logo = AppImageResource(imageResource: R.image.instagram_text_logo)
		public static let chatBackgroundDarkMask = AppImageResource(imageResource: R.image.chat_background_dark_mask)
		public static let chatBackgroundLightMask = AppImageResource(imageResource: R.image.chatBackground_light_mask)
		public static let chatBackgroundLightOverlay = AppImageResource(imageResource: R.image.chat_background_light_overlay)
		public static let placeholder = AppImageResource(imageResource: R.image.placeholder)
		public static let profilePhoto = AppImageResource(imageResource: R.image.profile_photo)
	}

	@MainActor
	public struct Colors {
		public static func customAdaptiveColor(_ colorScheme: ColorScheme, light: Color? = nil, dark: Color? = nil) -> Color {
			colorScheme == .dark ? (light ?? Colors.white) : (dark ?? Colors.black)
		}
		public static func customReversedAdaptiveColor(_ colorScheme: ColorScheme, light: Color? = nil, dark: Color? = nil) -> Color {
			colorScheme == .dark ? (dark ?? Colors.black) : (light ?? Colors.white)
		}
		public static let black = Color.black
		public static let background = Color(R.color.background)
		public static let white = Color.white
		public static let lightBlue = Color(R.color.lightBlue)
		public static let blue = Color(R.color.blue)
		public static let deepBlue = Color(R.color.deepBlue)
		public static let borderOutline = Color(R.color.borderOutline)
		public static let lightDark = Color(R.color.lightDark)
		public static let dark = Color(R.color.dark)
		public static let primaryDarkBlue = Color(R.color.primaryDarkBlue)
		public static let gray = Color(.systemGray)
		public static let brightGray = Color(R.color.brightGray)
		public static let darkGray = Color(R.color.darkGray)
		public static let emphasizeGrey = Color(R.color.emphasizeGrey)
		public static let emphasizeDarkGrey = Color(R.color.emphasizeDarkGrey)
		public static let red = Color(R.color.red)
		public static let bodyColor = Color(R.color.bodyColor)
		public static let displayColor = Color(R.color.displayColor)
		public static let decorationColor = Color(R.color.decorationColor)
		public static let appBarBackgroundColor = Color(R.color.appBar_backgroundColor)
		public static let appBarSurfaceTintColor = Color(R.color.appBar_surfaceTintColor)
		public static let bottomSheetBackgroundColor = Color(R.color.bottomSheet_backgroundColor)
		public static let bottomSheetSurfaceTintColor = Color(R.color.bottomSheet_surfaceTintColor)
		public static let bottomSheetModalBackgroundColor = Color(R.color.bottomSheet_modalBackgroundColor)
		public static let focusColor = Color(R.color.focusColor)
		public static let snackbarSuccessBackground = Color(R.color.snackbarSuccess)
		public static let snackbarErrorBackground = Color(R.color.snackbarError)
		public static let primaryContainer = Color(R.color.primaryContainer)
		
		public static let primaryGradient: [Color] = [
			Color(R.color.purple),
			Color(R.color.orange),
			Color(R.color.red_pink),
			Color(R.color.red_purple),
			Color(R.color.purple)
		]
		
		public static let primaryMessageBubbleGradient: [Color] = [
			Color(R.color.message_first),
			Color(R.color.message_second),
			Color(R.color.message_third),
			Color(R.color.message_fourth),
		]
		
		public static let primayBackgroundGradient: [Color] = [
			Color(R.color.background_first),
			Color(R.color.background_second),
			Color(R.color.background_third),
			Color(R.color.background_fourth),
		]
	}
}



@MainActor
public struct Animations {
	public let checkedAnimation = AnimationResource(animationFile: R.file.checkedAnimationJson)
}

@MainActor
public struct AppImageResource {
	public let imageResource: RswiftResources.ImageResource
	public init(imageResource: RswiftResources.ImageResource) {
		self.imageResource = imageResource
	}

	public func view(
		width: CGFloat? = nil,
		height: CGFloat? = nil,
		renderMode: Image.TemplateRenderingMode? = .template,
		contentMode: ContentMode = .fit,
		tint: Color? = nil
	) -> some View {
		Image(imageResource.name, bundle: .module)
			.renderingMode(renderMode)
			.resizable()
			.aspectRatio(contentMode: contentMode)
			.frame(maxWidth: width ?? .infinity, maxHeight: height ?? .infinity)
	}
}

public struct AnimationResource {
	private let animationFile: RswiftResources.FileResource

	init(animationFile: FileResource) {
		self.animationFile = animationFile
	}

	public func view(
		width: CGFloat? = nil,
		height: CGFloat? = nil
	) -> some View {
		LottieView(animation: .named(animationFile.name))
			.frame(width: width, height: height)
	}
}
