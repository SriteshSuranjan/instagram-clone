import SwiftUI

public enum ScaleStrength: CGFloat {
	case none = 0
	case xxxxs = 0.0325
	case xxxs = 0.0625
	case xxs = 0.125

	/// xs scale strength (0.25)
	case xs = 0.25

	/// md scale strength (0.5)
	case md = 0.5

	/// lg scale strength (0.75)
	case lg = 0.75

	/// xlg scale strength (1)
	case xlg = 1
}

// 基础的按钮动画效果配置
public struct ButtonAnimationConfig: Sendable {
	let scale: CGFloat
	let opacity: CGFloat
	let duration: Double
	let hapticFeedback: UIImpactFeedbackGenerator.FeedbackStyle?
	public init(
		scale: ScaleStrength = .xxs,
		opacity: CGFloat = 1.0,
		duration: Double = 0.2,
		hapticFeedback: UIImpactFeedbackGenerator.FeedbackStyle? = nil
	) {
		self.scale = 1 - scale.rawValue
		self.opacity = opacity
		self.duration = duration
		self.hapticFeedback = hapticFeedback
	}

	public static let scale = ButtonAnimationConfig(
		scale: .xxs,
		opacity: 1,
		duration: 0.2,
		hapticFeedback: nil
	)

	public static let fade = ButtonAnimationConfig(
		scale: .xxxxs,
		opacity: 0.5,
		duration: 0.2,
		hapticFeedback: nil
	)

	public static let none = ButtonAnimationConfig(
		scale: .none,
		opacity: 1.0,
		duration: 0.0,
		hapticFeedback: nil
	)
}

// 缩放效果
public struct ScaleButtonStyle: ButtonStyle {
	let config: ButtonAnimationConfig
	public init(config: ButtonAnimationConfig) {
		self.config = config
	}

	public func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.scaleEffect(configuration.isPressed ? config.scale : 1.0)
			.animation(.easeInOut(duration: config.duration), value: configuration.isPressed)
			.onChange(of: configuration.isPressed) { _, isPressed in
				if isPressed, let feedback = config.hapticFeedback {
					UIImpactFeedbackGenerator(style: feedback).impactOccurred()
				}
			}
	}
}

// 透明度效果
public struct OpacityButtonStyle: ButtonStyle {
	let config: ButtonAnimationConfig
	public init(config: ButtonAnimationConfig) {
		self.config = config
	}

	public func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.opacity(configuration.isPressed ? config.opacity : 1.0)
			.animation(.easeInOut(duration: config.duration), value: configuration.isPressed)
			.onChange(of: configuration.isPressed) { _, isPressed in
				if isPressed, let feedback = config.hapticFeedback {
					UIImpactFeedbackGenerator(style: feedback).impactOccurred()
				}
			}
	}
}

// 组合效果
public struct CombinedButtonStyle: ButtonStyle {
	let config: ButtonAnimationConfig
	public init(config: ButtonAnimationConfig) {
		self.config = config
	}

	public func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.scaleEffect(configuration.isPressed ? config.scale : 1.0)
			.opacity(configuration.isPressed ? config.opacity : 1.0)
			.animation(.easeInOut(duration: config.duration), value: configuration.isPressed)
			.onChange(of: configuration.isPressed) { _, isPressed in
				if isPressed, let feedback = config.hapticFeedback {
					UIImpactFeedbackGenerator(style: feedback).impactOccurred()
				}
			}
	}
}

// 自定义边框效果
public struct BorderedButtonStyle: ButtonStyle {
	let config: ButtonAnimationConfig
	let cornerRadius: CGFloat
	let borderWidth: CGFloat
	let borderColor: Color
	let backgroundColor: Color?
	public init(config: ButtonAnimationConfig, cornerRadius: CGFloat, borderWidth: CGFloat, borderColor: Color, backgroundColor: Color?) {
		self.config = config
		self.cornerRadius = cornerRadius
		self.borderWidth = borderWidth
		self.borderColor = borderColor
		self.backgroundColor = backgroundColor
	}

	public func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.background(backgroundColor ?? Color.clear)
			.overlay(
				RoundedRectangle(cornerRadius: cornerRadius)
					.stroke(borderColor, lineWidth: borderWidth)
			)
			.clipShape(RoundedRectangle(cornerRadius: cornerRadius))
			.scaleEffect(configuration.isPressed ? config.scale : 1.0)
			.opacity(configuration.isPressed ? config.opacity : 1.0)
			.animation(.easeInOut(duration: config.duration), value: configuration.isPressed)
			.onChange(of: configuration.isPressed) { _, isPressed in
				if isPressed, let feedback = config.hapticFeedback {
					UIImpactFeedbackGenerator(style: feedback).impactOccurred()
				}
			}
	}
}

public extension Button {
	func scaleEffect(config: ButtonAnimationConfig = .scale) -> some View {
		buttonStyle(ScaleButtonStyle(config: config))
	}

	func fadeEffect(config: ButtonAnimationConfig = .fade) -> some View {
		buttonStyle(OpacityButtonStyle(config: config))
	}

	func noneEffect(config: ButtonAnimationConfig = .none) -> some View {
		buttonStyle(CombinedButtonStyle(config: config))
	}
}
