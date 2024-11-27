import SwiftUI

public typealias SimpleAppButton = AppButton<EmptyView, EmptyView>

/// Button 的样式配置
@MainActor
public struct AppButtonStyle: Sendable {
	let foregroundColor: Color?
	let backgroundColor: Color?
	let textStyle: AppTextStyle?
	let cornerRadius: CGFloat
	let padding: EdgeInsets
	let fullWidth: Bool
	public init(
		foregroundColor: Color? = nil,
		backgroundColor: Color? = nil,
		textStyle: AppTextStyle? = UITextStyle.button,
		cornerRadius: CGFloat = 4,
		padding: EdgeInsets = EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16),
		fullWidth: Bool = false
	) {
		self.foregroundColor = foregroundColor
		self.backgroundColor = backgroundColor
		self.textStyle = textStyle
		self.cornerRadius = cornerRadius
		self.padding = padding
		self.fullWidth = fullWidth
	}
}

/// 按钮加载状态的配置
public struct LoadingConfig {
	let scale: CGFloat
	let color: Color?
		
	public init(scale: CGFloat = 0.6, color: Color? = nil) {
		self.scale = scale
		self.color = color
	}
}

public struct AppButton<Child: View, Icon: View>: View {
	private let text: String?
	private let action: () -> Void
	private let isDialogButton: Bool
	private let isDefaultAction: Bool
	private let isDestructiveAction: Bool
	private let style: AppButtonStyle
	private let icon: (() -> Icon)?
	private let iconScale: CGFloat
	private let loading: Bool
	private let loadingConfig: LoadingConfig
	private let outlined: Bool
	private let width: CGFloat?
	private let height: CGFloat?
	private let maxLines: Int?
	private let child: (() -> Child)?
		
	public init(
		_ text: String? = nil,
		action: @escaping () -> Void = {},
		isDialogButton: Bool = false,
		isDefaultAction: Bool = false,
		isDestructiveAction: Bool = false,
		style: AppButtonStyle = AppButtonStyle(),
		icon: (() -> Icon)? = nil,
		iconScale: CGFloat = 1.0,
		loading: Bool = false,
		loadingConfig: LoadingConfig = LoadingConfig(),
		outlined: Bool = false,
		width: CGFloat? = nil,
		height: CGFloat? = nil,
		maxLines: Int? = nil,
		child: (() -> Child)? = nil
	) {
		self.text = text
		self.action = action
		self.isDialogButton = isDialogButton
		self.isDefaultAction = isDefaultAction
		self.isDestructiveAction = isDestructiveAction
		self.style = style
		self.icon = icon
		self.iconScale = iconScale
		self.loading = loading
		self.loadingConfig = loadingConfig
		self.outlined = outlined
		self.width = width
		self.height = height
		self.maxLines = maxLines
		self.child = child
	}
		
	// 快捷构造方法，类似 Flutter 版本的 auth 构造
	public static func auth(
		_ text: String,
		action: @escaping () -> Void,
		outlined: Bool = true,
		style: AppButtonStyle = AppButtonStyle(fullWidth: true)
	) -> AppButton {
		AppButton(
			text,
			action: action,
			style: style,
			outlined: outlined
		)
	}
		
	// 快捷构造方法，用于创建加载中按钮
	public static func inProgress(
		scale: CGFloat = 1,
		style: AppButtonStyle = AppButtonStyle()
	) -> AppButton {
		AppButton(
			style: style,
			loading: true,
			loadingConfig: LoadingConfig(scale: scale)
		)
	}
		
	public var body: some View {
		Group {
			if isDialogButton {
				buildDialogButton()
			} else if loading {
				buildLoadingButton()
			} else if let icon = icon {
				buildIconButton(icon: icon())
			} else {
				buildStandardButton()
			}
		}
	}
		
	@ViewBuilder
	private func buildDialogButton() -> some View {
		if UIDevice.current.userInterfaceIdiom == .phone {
			Button(action: action) {
				buildButtonContent()
			}
			.buttonStyle(.plain)
			.foregroundColor(isDestructiveAction ? .red : nil)
			.fontWeight(isDefaultAction ? .bold : nil)
		} else {
			Button(action: action) {
				buildButtonContent()
			}
		}
	}
		
	@ViewBuilder
	private func buildLoadingButton() -> some View {
		Button(action: {}) {
			ProgressView()
				.progressViewStyle(.circular)
				.scaleEffect(loadingConfig.scale)
				.tint(style.foregroundColor)
				.frame(maxWidth: style.fullWidth ? .infinity : nil)
		}
		.buttonStyle(buildButtonStyle())
	}
		
	@ViewBuilder
	private func buildIconButton(icon: Icon) -> some View {
		Button(action: action) {
			HStack(spacing: 8) {
				icon
					.scaleEffect(iconScale)
				buildButtonContent()
			}
			.frame(maxWidth: style.fullWidth ? .infinity : nil)
		}
		.buttonStyle(buildButtonStyle())
		
		
	}
		
	@ViewBuilder
	private func buildStandardButton() -> some View {
		Button {
			action()
		} label: {
			buildButtonContent()
				.frame(maxWidth: style.fullWidth ? .infinity : nil)
		}
		.buttonStyle(buildButtonStyle())
	}
		
	@ViewBuilder
	private func buildButtonContent() -> some View {
		if let child {
			child()
		} else if let text = text {
			Text(text)
				.lineLimit(maxLines)
				.font(style.textStyle?.font ?? UITextStyle.button.font)
		}
	}
	
	private func buildButtonStyle() -> some ButtonStyle {
		UnifiedAppButtonStyle(style: style, outlined: outlined)
	}
}

struct UnifiedAppButtonStyle: ButtonStyle {
	let style: AppButtonStyle
	let outlined: Bool
		
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.foregroundStyle(style.foregroundColor ?? (outlined ? .blue : .white))
			.padding(style.padding)
			.background(
				Group {
					if outlined {
						RoundedRectangle(cornerRadius: style.cornerRadius)
							.stroke(style.foregroundColor ?? .blue, lineWidth: 1)
					} else {
						RoundedRectangle(cornerRadius: style.cornerRadius)
							.fill(style.backgroundColor ?? .blue)
					}
				}
			)
			.contentShape(Rectangle())
	}
}

// 填充样式按钮
public struct FilledAppButtonStyle: PrimitiveButtonStyle {
	let style: AppButtonStyle
		
	public func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.foregroundStyle(style.foregroundColor ?? .white)
			.padding(style.padding)
			.background(style.backgroundColor ?? .blue)
			.cornerRadius(style.cornerRadius)
//			.scaleEffect(configuration.isPressed ? 0.98 : 1.0)
//			.animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
	}
}

// 边框样式按钮
public struct OutlinedAppButtonStyle: PrimitiveButtonStyle {
	let style: AppButtonStyle
		
	public func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.foregroundStyle(style.foregroundColor ?? .blue)
			.padding(style.padding)
			.background(
				RoundedRectangle(cornerRadius: style.cornerRadius)
					.stroke(style.foregroundColor ?? .blue, lineWidth: 1)
			)
//			.scaleEffect(configuration.isPressed ? 0.98 : 1.0)
//			.animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
	}
}
