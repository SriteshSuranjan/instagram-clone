import SwiftUI

public struct AppTextFieldModifier<LeadingView: View, TrailingView: View>: ViewModifier {
	// Style properties
	var font: Font?
	var foregroundColor: Color?
	var accentColor: Color?
	var backgroundColor: Color?
		
	// TextField properties
	var isEnabled: Bool = true
	var autocorrection: Bool = true
	var autocapitalization: TextInputAutocapitalization = .never
	var keyboardType: UIKeyboardType = .default
	var returnKeyType: UIReturnKeyType = .default
	var contentType: UITextContentType?
		
	// Layout properties
	var padding: EdgeInsets = .init(top: 8, leading: 12, bottom: 8, trailing: 12)
	var height: CGFloat? // 添加高度属性
	var maxWidth: CGFloat?
		
	// Decorative views
	var leadingView: (() -> LeadingView)?
	var trailingView: (() -> TrailingView)?
		
	// Border style
	var cornerRadius: CGFloat = 0
	var borderColor: Color = .clear
	var borderWidth: CGFloat = 0
		
	// Handlers
	var onEditingChanged: ((Bool) -> Void)?
	var onSubmit: (() -> Void)?
	var validator: ((String) -> Bool)?
	var errorMessage: String?
		
	public func body(content: Content) -> some View {
//		VStack(alignment: .leading, spacing: 0) {
			HStack(spacing: 8) {
				if let leadingView = leadingView {
					leadingView()
				}
				
				content
					.font(font)
					.foregroundColor(foregroundColor)
					.tint(accentColor)
					.textInputAutocapitalization(autocapitalization)
					.autocorrectionDisabled(!autocorrection)
					.disabled(!isEnabled)
					.textContentType(contentType)
					.keyboardType(keyboardType)
					.submitScope(true)
					.onSubmit {
						onSubmit?()
					}
				
				if let trailingView = trailingView {
					trailingView()
				}
			}
			.padding(padding)
			.frame(maxWidth: maxWidth ?? .infinity)
			.frame(height: height ?? 44)
			.background(backgroundColor ?? Color(.systemBackground))
			.clipShape(RoundedRectangle(cornerRadius: cornerRadius))
			.overlay(
				RoundedRectangle(cornerRadius: cornerRadius)
					.stroke(borderColor, lineWidth: borderWidth)
			)
	}
}

// MARK: - View Extension

public extension View {
	func appTextField<LeadingView: View, TrailingView: View>(
		font: Font? = nil,
		foregroundColor: Color? = nil,
		accentColor: Color? = nil,
		backgroundColor: Color? = nil,
		isEnabled: Bool = true,
		autocorrection: Bool = false,
		autocapitalization: TextInputAutocapitalization = .never,
		keyboardType: UIKeyboardType = .default,
		returnKeyType: UIReturnKeyType = .default,
		contentType: UITextContentType? = nil,
		padding: EdgeInsets = EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12),
		maxWidth: CGFloat? = .infinity,
		height: CGFloat? = 48,
		cornerRadius: CGFloat = 4,
		borderColor: Color = .clear,
		borderWidth: CGFloat = 0,
		onEditingChanged: ((Bool) -> Void)? = nil,
		onSubmit: (() -> Void)? = nil,
		validator: ((String) -> Bool)? = nil,
		@ViewBuilder leadingView: @escaping (() -> LeadingView) = { EmptyView() },
		@ViewBuilder trailingView: @escaping (() -> TrailingView) = { EmptyView() },
		errorMessage: String? = nil
	) -> some View {
		modifier(AppTextFieldModifier(
			font: font,
			foregroundColor: foregroundColor,
			accentColor: accentColor,
			backgroundColor: backgroundColor,
			isEnabled: isEnabled,
			autocorrection: autocorrection,
			autocapitalization: autocapitalization,
			keyboardType: keyboardType,
			returnKeyType: returnKeyType,
			contentType: contentType,
			padding: padding,
			height: height,
			maxWidth: maxWidth,
			leadingView: leadingView,
			trailingView: trailingView,
			cornerRadius: cornerRadius,
			borderColor: borderColor,
			borderWidth: borderWidth,
			onEditingChanged: onEditingChanged,
			onSubmit: onSubmit,
			validator: validator,
			errorMessage: errorMessage
		))
	}
}

public extension View {
//	func appTextFieldLeadingView<Content: View>(@ViewBuilder content: @escaping () -> Content) -> some View {
//		appTextField(leadingView: { AnyView(content()) })
//	}
//		
//	func appTextFieldTrailingView<Content: View>(@ViewBuilder content: @escaping () -> Content) -> some View {
//		appTextField(trailingView: { AnyView(content()) })
//	}
}

#Preview {
	ScrollView {
		VStack {
			AppLogoView(
				width: .infinity,
				height: 50,
				color: Assets.Colors.bodyColor,
				contentMode: .fit
			)
			.padding(.top, AppSpacing.xxxlg * 2)
			TextField("Email", text: .constant("7e12873@gmail.com"))
				.appTextField(
					foregroundColor: Assets.Colors.bodyColor,
					accentColor: Assets.Colors.bodyColor,
					backgroundColor: Assets.Colors.customReversedAdaptiveColor(ColorScheme.dark, light: Assets.Colors.brightGray, dark: Assets.Colors.dark),
					keyboardType: .emailAddress,
					returnKeyType: .next
				)
				.padding()
		}
	}
}
