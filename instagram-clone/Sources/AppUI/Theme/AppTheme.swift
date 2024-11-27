import SwiftUI

// MARK: - Theme Protocol

// @MainActor
// public protocol AppThemeProtocol {
//	var colorTheme: ColorTheme { get }
//	var textTheme: TextTheme { get }
// }

// @MainActor
// private let darkTextTheme = TextTheme(
//	displayLarge: ContentTextStyle.headline1,
//	displayMedium: ContentTextStyle.headline2,
//	displaySmall: ContentTextStyle.headline3,
//	headlineLarge: ContentTextStyle.headline4,
//	headlineMedium: ContentTextStyle.headline5,
//	headlineSmall: ContentTextStyle.headline6,
//	titleLarge: ContentTextStyle.headline7,
//	titleMedium: ContentTextStyle.subtitle1,
//	titleSmall: ContentTextStyle.subtitle2,
//	bodyLarge: ContentTextStyle.bodyText1,
//	bodyMedium: ContentTextStyle.bodyText2,
//	labelLarge: ContentTextStyle.button,
//	bodySmall: ContentTextStyle.caption,
//	labelSmall: ContentTextStyle.overline,
//	textColor: Assets.colors.white
// )
//

// MARK: - Color Theme
//@MainActor
//public enum ColorTheme: String, CaseIterable {
//	case system = "System"
//	case light = "Light"
//	case dark = "Dark"
//	
//	public var colorScheme: ColorScheme? {
//		switch self {
//		case .system: return nil
//		case .light: return .light
//		case .dark: return .dark
//		}
//	}
//	
//	public func background(_ systemColorScheme: ColorScheme) -> Color {
//		switch self {
//		case .system: return systemColorScheme == .dark ? Assets.colors.black : Assets.colors.white
//		case .light: return Assets.colors.white
//		case .dark: return Assets.colors.black
//		}
//	}
//	
//	public func primary(_ systemColorScheme: ColorScheme) -> Color {
//		switch self {
//		case .system: return systemColorScheme == .dark ? Assets.colors.black : Assets.colors.white
//		case .light: return Assets.colors.white
//		case .dark: return Assets.colors.black
//		}
//	}
//	
//	public func bodyColor() -> Color {
//		Assets.colors.bodyColor
//	}
//	
//	public func displayColor() -> Color {
//		Assets.colors.displayColor
//	}
//	
//	public func decorationColor() -> Color {
//		Assets.colors.decorationColor
//	}
//	
//	public func appBarBackgroundColor() -> Color {
//		Assets.colors.appBarBackgroundColor
//	}
//	
//	public func appBarSurfaceTintColor() -> Color {
//		Assets.colors.appBarSurfaceTintColor
//	}
//	
//	public func bottomSheetSurfaceTintColor() -> Color {
//		Assets.colors.bottomSheetSurfaceTintColor
//	}
//	
//	public func bottomSheetBackgroundColor() -> Color {
//		Assets.colors.bottomSheetBackgroundColor
//	}
//	
//	public func bottomSheetModalBackgroundColor() -> Color {
//		Assets.colors.bottomSheetModalBackgroundColor
//	}
//	
//	public func adaptiveColor(_ systemColorScheme: ColorScheme) -> Color {
//		switch self {
//		case .system: return systemColorScheme == .dark ? Assets.colors.white : Assets.colors.black
//		case .light: return Assets.colors.black
//		case .dark: return Assets.colors.white
//		}
//	}
//	
//	public func reversedAdaptiveColor(_ systemColorScheme: ColorScheme) -> Color {
//		switch self {
//		case .system: return systemColorScheme == .dark ? Assets.colors.black : Assets.colors.white
//		case .light: return Assets.colors.white
//		case .dark: return Assets.colors.black
//		}
//	}
//	
//	public func customAdaptiveColor(_ systemColorScheme: ColorTheme, light: Color?, dark: Color?) -> Color {
//		switch self {
//		case .system: return systemColorScheme == .dark ? (light ?? Assets.colors.white) : (dark ?? Assets.colors.black)
//		case .light: return dark ?? Assets.colors.black
//		case .dark: return light ?? Assets.colors.white
//		}
//	}
//	
//	public func customReversedAdpativeColor(_ systemColorScheme: ColorTheme, light: Color?, dark: Color?) -> Color {
//		switch self {
//		case .system: return systemColorScheme == .dark ? (dark ?? Assets.colors.black) : (light ?? Assets.colors.white)
//		case .light: return light ?? Assets.colors.white
//		case .dark: return dark ?? Assets.colors.black
//		}
//	}
//}

// MARK: - Text Theme

@MainActor
public struct TextTheme {
	public let displayLarge: AppTextStyle
	public let displayMedium: AppTextStyle
	public let displaySmall: AppTextStyle
	public let headlineLarge: AppTextStyle
	public let headlineMedium: AppTextStyle
	public let headlineSmall: AppTextStyle
	public let titleLarge: AppTextStyle
	public let titleMedium: AppTextStyle
	public let titleSmall: AppTextStyle
	public let bodyLarge: AppTextStyle
	public let bodyMedium: AppTextStyle
	public let labelLarge: AppTextStyle
	public let bodySmall: AppTextStyle
	public let labelSmall: AppTextStyle
	
	public nonisolated init(
		displayLarge: AppTextStyle,
		displayMedium: AppTextStyle,
		displaySmall: AppTextStyle,
		headlineLarge: AppTextStyle,
		headlineMedium: AppTextStyle,
		headlineSmall: AppTextStyle,
		titleLarge: AppTextStyle,
		titleMedium: AppTextStyle,
		titleSmall: AppTextStyle,
		bodyLarge: AppTextStyle,
		bodyMedium: AppTextStyle,
		labelLarge: AppTextStyle,
		bodySmall: AppTextStyle,
		labelSmall: AppTextStyle
	) {
		self.displayLarge = displayLarge
		self.displayMedium = displayMedium
		self.displaySmall = displaySmall
		self.headlineLarge = headlineLarge
		self.headlineMedium = headlineMedium
		self.headlineSmall = headlineSmall
		self.titleLarge = titleLarge
		self.titleMedium = titleMedium
		self.titleSmall = titleSmall
		self.bodyLarge = bodyLarge
		self.bodyMedium = bodyMedium
		self.labelLarge = labelLarge
		self.bodySmall = bodySmall
		self.labelSmall = labelSmall
	}

	@MainActor
	static var defaultValue: TextTheme {
		TextTheme(
			displayLarge: ContentTextStyle.headline1,
			displayMedium: ContentTextStyle.headline2,
			displaySmall: ContentTextStyle.headline3,
			headlineLarge: ContentTextStyle.headline4,
			headlineMedium: ContentTextStyle.headline5,
			headlineSmall: ContentTextStyle.headline6,
			titleLarge: ContentTextStyle.headline7,
			titleMedium: ContentTextStyle.subtitle1,
			titleSmall: ContentTextStyle.subtitle2,
			bodyLarge: ContentTextStyle.bodyText1,
			bodyMedium: ContentTextStyle.bodyText2,
			labelLarge: ContentTextStyle.button,
			bodySmall: ContentTextStyle.caption,
			labelSmall: ContentTextStyle.overline
		)
	}
}

private struct TextThemeKey: @preconcurrency EnvironmentKey {
	@MainActor
	static let defaultValue: TextTheme = .defaultValue
}

 public extension EnvironmentValues {
	 var textTheme: TextTheme {
		get { self[TextThemeKey.self] }
		set { self[TextThemeKey.self] = newValue }
	}
 }

// public extension EnvironmentValues {
//	@Entry var textTheme: TextTheme = .init(
//		displayLarge: ContentTextStyle.headline1,
//		displayMedium: ContentTextStyle.headline2,
//		displaySmall: ContentTextStyle.headline3,
//		headlineLarge: ContentTextStyle.headline4,
//		headlineMedium: ContentTextStyle.headline5,
//		headlineSmall: ContentTextStyle.headline6,
//		titleLarge: ContentTextStyle.headline7,
//		titleMedium: ContentTextStyle.subtitle1,
//		titleSmall: ContentTextStyle.subtitle2,
//		bodyLarge: ContentTextStyle.bodyText1,
//		bodyMedium: ContentTextStyle.bodyText2,
//		labelLarge: ContentTextStyle.button,
//		bodySmall: ContentTextStyle.caption,
//		labelSmall: ContentTextStyle.overline
//	)
// }

// MARK: - Light Theme

// @MainActor
// public struct AppTheme: AppThemeProtocol {
//	public let brightness: ColorScheme = .light
//	public let backgroundColor: Color = AppColors.white
//	public let primary: Color = AppColors.black
//
//	public var textTheme: TextTheme {
//		TextTheme(
//			displayLarge: ContentTextStyle.headline1,
//			displayMedium: ContentTextStyle.headline2,
//			displaySmall: ContentTextStyle.headline3,
//			headlineLarge: ContentTextStyle.headline4,
//			headlineMedium: ContentTextStyle.headline5,
//			headlineSmall: ContentTextStyle.headline6,
//			titleLarge: ContentTextStyle.headline7,
//			titleMedium: ContentTextStyle.subtitle1,
//			titleSmall: ContentTextStyle.subtitle2,
//			bodyLarge: ContentTextStyle.bodyText1,
//			bodyMedium: ContentTextStyle.bodyText2,
//			labelLarge: ContentTextStyle.button,
//			bodySmall: ContentTextStyle.caption,
//			labelSmall: ContentTextStyle.overline,
//			textColor: AppColors.black
//		)
//	}
// }
//
//// MARK: - Dark Theme
//
// struct AppDarkTheme: AppThemeProtocol {
//	let brightness: ColorScheme = .dark
//	let backgroundColor: Color = AppColors.black
//	let primary: Color = AppColors.white
//
//	var textTheme: TextTheme {
//		TextTheme(
//			displayLarge: ContentTextStyle.headline1,
//			displayMedium: ContentTextStyle.headline2,
//			displaySmall: ContentTextStyle.headline3,
//			headlineLarge: ContentTextStyle.headline4,
//			headlineMedium: ContentTextStyle.headline5,
//			headlineSmall: ContentTextStyle.headline6,
//			titleLarge: ContentTextStyle.headline7,
//			titleMedium: ContentTextStyle.subtitle1,
//			titleSmall: ContentTextStyle.subtitle2,
//			bodyLarge: ContentTextStyle.bodyText1,
//			bodyMedium: ContentTextStyle.bodyText2,
//			labelLarge: ContentTextStyle.button,
//			bodySmall: ContentTextStyle.caption,
//			labelSmall: ContentTextStyle.overline,
//			textColor: AppColors.white
//		)
//	}
// }
//
//// MARK: - Theme Environment
//
// private struct ThemeKey: @preconcurrency EnvironmentKey {
//	@MainActor
//	static let defaultValue: AppThemeProtocol = AppTheme()
// }
//
// public extension EnvironmentValues {
//	var appTheme: AppThemeProtocol {
//		get { self[ThemeKey.self] }
//		set { self[ThemeKey.self] = newValue }
//	}
// }
//
//// MARK: - Theme Modifier
//
// public struct ThemeModifier: ViewModifier {
//	public let theme: AppThemeProtocol
//
//	public func body(content: Content) -> some View {
//		content
//			.environment(\.appTheme, theme)
//			.preferredColorScheme(theme.brightness)
//			.background(theme.backgroundColor)
//	}
// }
//
//// MARK: - View Extensions
//
// public extension View {
//	func appTheme(_ theme: AppThemeProtocol) -> some View {
//		modifier(ThemeModifier(theme: theme))
//	}
// }
//
//// MARK: - UI Components Styling
// public enum AppComponents {
//
//	public struct NavigationBarModifier: ViewModifier {
//		@Environment(\.appTheme) var theme
//
//		public func body(content: Content) -> some View {
//			content
//				.navigationBarTitleDisplayMode(.inline)
//				.toolbarBackground(theme.backgroundColor, for: .navigationBar)
//				.toolbarBackground(.visible, for: .navigationBar)
//		}
//	}
//	@MainActor public static func navigationBarStyle() -> NavigationBarModifier {
//		NavigationBarModifier()
//	}
// }
