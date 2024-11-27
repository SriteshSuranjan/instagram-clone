import RswiftResources
import SwiftUI

@MainActor
public struct AppTextStyle {
	let size: CGFloat
	let weight: Font.Weight
	let lineHeight: CGFloat
	let letterSpacing: CGFloat

	public var font: Font {
		let fontInfo: (String, String) = {
			switch weight {
			case .bold:
				return ("Inter", "Inter-Bold")
			case .heavy, .black:
				return ("Inter", "Inter-ExtraBold")
			case .ultraLight:
				return ("Inter", "Inter-ExtraLight")
			case .light:
				return ("Inter", "Inter-Light")
			case .medium:
				return ("Inter", "Inter-Medium")
			case .regular:
				return ("Inter","Inter-Regular")
			case .semibold:
				return ("Inter", "Inter-SemiBold")
			default:
				return ("Montserrat", "Montserrat-Mediem")
			}
		}()
		return Font.custom(fontInfo.1, size: size, relativeTo: .body)
			.weight(weight)
	}
}

@MainActor
public enum UITextStyle {
	private static let baseStyle = AppTextStyle(
		size: 16,
		weight: AppFontWeight.medium,
		lineHeight: 1.5,
		letterSpacing: 0
	)

	public static let display2 = AppTextStyle(
		size: 57,
		weight: AppFontWeight.bold,
		lineHeight: 1.12,
		letterSpacing: -0.25
	)

	public static let display3 = AppTextStyle(
		size: 45,
		weight: AppFontWeight.bold,
		lineHeight: 1.15,
		letterSpacing: 0
	)

	public static let headline1 = AppTextStyle(
		size: 36,
		weight: AppFontWeight.bold,
		lineHeight: 1.22,
		letterSpacing: 0
	)
	
	public static let headline2 = AppTextStyle(
		size: 32,
		weight: AppFontWeight.bold,
		lineHeight: 1.22,
		letterSpacing: 0
	)
	
	public static let headline3 = AppTextStyle(
		size: 28,
		weight: AppFontWeight.semiBold,
		lineHeight: 1.28,
		letterSpacing: 0
	)
	
	public static let headline4 = AppTextStyle(
		size: 22,
		weight: AppFontWeight.regular,
		lineHeight: 1.33,
		letterSpacing: 0
	)
	
	public static let headline5 = AppTextStyle(
		size: 22,
		weight: AppFontWeight.regular,
		lineHeight: 1.27,
		letterSpacing: 0
	)
	
	public static let headline6 = AppTextStyle(
		size: 22,
		weight: AppFontWeight.regular,
		lineHeight: 1.33,
		letterSpacing: 0
	)
	
	public static let subtitle1 = AppTextStyle(
		size: 16,
		weight: AppFontWeight.medium,
		lineHeight: 1.5,
		letterSpacing: 0.1
	)
	
	public static let subtitle2 = AppTextStyle(
		size: 14,
		weight: AppFontWeight.medium,
		lineHeight: 1.42,
		letterSpacing: 0.1
	)
	
	public static let bodyText1 = AppTextStyle(
		size: 16,
		weight: AppFontWeight.medium,
		lineHeight: 1.5,
		letterSpacing: 0.5
	)
	
	public static let bodyText2 = AppTextStyle(
		size: 14,
		weight: AppFontWeight.medium,
		lineHeight: 1.42,
		letterSpacing: 0.25
	)
	
	public static let caption = AppTextStyle(
		size: 12,
		weight: AppFontWeight.medium,
		lineHeight: 1.33,
		letterSpacing: 0.4
	)
	
	public static let button = AppTextStyle(
		size: 16,
		weight: AppFontWeight.medium,
		lineHeight: 1.42,
		letterSpacing: 0.1
	)
	
	public static let overline = AppTextStyle(
		size: 12,
		weight: AppFontWeight.medium,
		lineHeight: 1.33,
		letterSpacing: 0.5
	)
	
	public static let labelSmall = AppTextStyle(
		size: 11,
		weight: AppFontWeight.medium,
		lineHeight: 1.45,
		letterSpacing: 0.5
	)
}

@MainActor
public enum ContentTextStyle {
	private static let baseTextStyle = AppTextStyle(
		size: 16,
		weight: AppFontWeight.medium,
		lineHeight: 1.5,
		letterSpacing: 0
	)
	public static let display1 = AppTextStyle(
		size: 64,
		weight: AppFontWeight.bold,
		lineHeight: 1.18,
		letterSpacing: -0.5
	)
	public static let display2 = AppTextStyle(
		size: 57,
		weight: AppFontWeight.bold,
		lineHeight: 1.12,
		letterSpacing: -0.25
	)
	public static let display3 = AppTextStyle(
		size: 45,
		weight: AppFontWeight.bold,
		lineHeight: 1.15,
		letterSpacing: 0
	)
	public static let headline1 = AppTextStyle(
		size: 57,
		weight: AppFontWeight.semiBold,
		lineHeight: 1.22,
		letterSpacing: 0
	)
	public static let headline2 = AppTextStyle(
		size: 45,
		weight: AppFontWeight.medium,
		lineHeight: 1.25,
		letterSpacing: 0
	)
	public static let headline3 = AppTextStyle(
		size: 36,
		weight: AppFontWeight.medium,
		lineHeight: 1.28,
		letterSpacing: 0
	)
	public static let headline4 = AppTextStyle(
		size: 32,
		weight: AppFontWeight.semiBold,
		lineHeight: 1.33,
		letterSpacing: 0
	)
	public static let headline5 = AppTextStyle(
		size: 28,
		weight: AppFontWeight.semiBold,
		lineHeight: 1.33,
		letterSpacing: 0
	)
	public static let headline6 = AppTextStyle(
		size: 24,
		weight: AppFontWeight.bold,
		lineHeight: 1.27,
		letterSpacing: 0
	)
	public static let headline7 = AppTextStyle(
		size: 22,
		weight: AppFontWeight.semiBold,
		lineHeight: 1.33,
		letterSpacing: 0
	)
	public static let subtitle1 = AppTextStyle(
		size: 16,
		weight: AppFontWeight.medium,
		lineHeight: 1.5,
		letterSpacing: 0.1
	)
	public static let subtitle2 = AppTextStyle(
		size: 14,
		weight: AppFontWeight.medium,
		lineHeight: 1.5,
		letterSpacing: 0.5
	)
	public static let bodyText1 = AppTextStyle(
		size: 16,
		weight: AppFontWeight.medium,
		lineHeight: 1.5,
		letterSpacing: 0.5
	)
	public static let bodyText2 = AppTextStyle(
		size: 14,
		weight: AppFontWeight.medium,
		lineHeight: 1.42,
		letterSpacing: 0.25
	)
	public static let button = AppTextStyle(
		size: 14,
		weight: AppFontWeight.bold,
		lineHeight: 1.42,
		letterSpacing: 0.1
	)
	public static let caption = AppTextStyle(
		size: 12,
		weight: AppFontWeight.medium,
		lineHeight: 1.33,
		letterSpacing: 0.4
	)
	public static let overline = AppTextStyle(
		size: 12,
		weight: AppFontWeight.semiBold,
		lineHeight: 1.33,
		letterSpacing: 0.5
	)
	public static let labelSmall = AppTextStyle(
		size: 11,
		weight: AppFontWeight.medium,
		lineHeight: 1.45,
		letterSpacing: 0.5
	)
}

public struct AppTextStyleModifier: ViewModifier {
	let style: AppTextStyle
		
	public func body(content: Content) -> some View {
		content
			.font(style.font)
			.lineSpacing((style.lineHeight - 1.0) * style.size)
			.tracking(style.letterSpacing)
	}
}

// View扩展
public extension View {
	@MainActor
	func appTextStyle(_ style: AppTextStyle) -> some View {
		modifier(AppTextStyleModifier(style: style))
	}
}

// Text扩展
public extension Text {
	@MainActor
	func uiStyle(_ style: AppTextStyle) -> some View {
		appTextStyle(style)
	}

	@MainActor
	func contentStyle(_ style: AppTextStyle) -> some View {
		appTextStyle(style)
	}
}
