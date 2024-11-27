//import OSLog
//import SwiftUI
//
//public enum TapEffect {
//	case scale
//	case fade
//	case both
//	case none
//}
//
//public enum ScaleStrength {
//	case xs
//	case sm
//	case md
//	case lg
//
//	public var value: CGFloat {
//		switch self {
//		case .xs: return 0.98
//		case .sm: return 0.95
//		case .md: return 0.90
//		case .lg: return 0.85
//		}
//	}
//}
//
//public struct Tappable<Content: View>: View {
//	// MARK: - Properties
//
//	let content: Content
//	var onTap: (() -> Void)?
//	var onLongPress: (() -> Void)?
//	var onLongPressMove: ((DragGesture.Value) -> Void)?
//	var onLongPressEnd: ((DragGesture.Value) -> Void)?
//	var cornerRadius: CGFloat
//	var backgroundColor: Color?
//	var animationEffect: TapEffect
//	var scaleStrength: ScaleStrength
//	var scaleAlignment: Alignment
//	var hapticFeedback: Bool
//	var isDisabled: Bool
//		 var borderWidth: CGFloat
//		 var borderColor: Color
//
//	@State private var isPressed = false
//	@GestureState private var isDetectingLongPress = false
//
//	// MARK: - Initialization
//
//	public init(
//		@ViewBuilder content: () -> Content,
//		onTap: (() -> Void)? = nil,
//		onLongPress: (() -> Void)? = nil,
//		onLongPressMove: ((DragGesture.Value) -> Void)? = nil,
//		onLongPressEnd: ((DragGesture.Value) -> Void)? = nil,
//		cornerRadius: CGFloat = 0,
//		backgroundColor: Color? = nil,
//		animationEffect: TapEffect = .fade,
//		scaleStrength: ScaleStrength = .xs,
//		scaleAlignment: Alignment = .center,
//		hapticFeedback: Bool = true,
//		isDisabled: Bool = false,
//		borderWidth: CGFloat = 1.0,
//		borderColor: Color = .clear
//	) {
//		self.content = content()
//		self.onTap = onTap
//		self.onLongPress = onLongPress
//		self.onLongPressMove = onLongPressMove
//		self.onLongPressEnd = onLongPressEnd
//		self.cornerRadius = cornerRadius
//		self.backgroundColor = backgroundColor
//		self.animationEffect = animationEffect
//		self.scaleStrength = scaleStrength
//		self.scaleAlignment = scaleAlignment
//		self.hapticFeedback = hapticFeedback
//		self.isDisabled = isDisabled
//		self.borderWidth = borderWidth
//		self.borderColor = borderColor
//	}
//
//	// MARK: - Body
//
//	public var body: some View {
//		let longPress = LongPressGesture(minimumDuration: 0.3)
//			.updating($isDetectingLongPress) { currentState, gestureState, _ in
//				gestureState = currentState
//			}
//			.onEnded { _ in
//				guard !isDisabled else { return }
//				if hapticFeedback {
//					UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
//				}
//				onLongPress?()
//			}
//
//		let drag = DragGesture(minimumDistance: 0)
//			.onChanged { value in
//				guard !isDisabled else { return }
//				onLongPressMove?(value)
//			}
//			.onEnded { value in
//				guard !isDisabled else { return }
//				onLongPressEnd?(value)
//			}
//
//		let combinedGesture = longPress
//			.sequenced(before: drag)
//
//		content
//			.overlay {
//				RoundedRectangle(cornerRadius: cornerRadius)
//					.stroke(borderColor, lineWidth: borderWidth)
//			}
//			.background(backgroundColor ?? Color.clear)
//			.clipShape(RoundedRectangle(cornerRadius: cornerRadius))
//			.scaleEffect(
//				scale,
//				anchor: .center
//			)
//			.opacity(opacity)
//			.animation(.easeInOut(duration: 0.2), value: isPressed)
//			.animation(.easeInOut(duration: 0.2), value: isDetectingLongPress)
//			.animation(.easeInOut(duration: 0.2), value: isDisabled)
//			.contentShape(Rectangle())
//			.gesture(
//				onLongPress != nil ? combinedGesture : nil
//			)
//			.simultaneousGesture(
//				TapGesture()
//					.onEnded { _ in
//						guard !isDisabled else { return }
//						handleTap()
//					}
//			)
//			.pressEvents(
//				onPress: {
//					guard !isDisabled else { return }
//					isPressed = true
//				},
//				onRelease: {
//					guard !isDisabled else { return }
//					isPressed = false
//				}
//			)
//	}
//
//	// MARK: - Helper Properties
//
//	private var scale: CGFloat {
//		switch animationEffect {
//		case .scale, .both:
//			return isPressed ? scaleStrength.value : 1.0
//		case .fade:
//			return 1.0
//		case .none:
//			return 1.0
//		}
//	}
//
//	private var opacity: CGFloat {
//		switch animationEffect {
//		case .fade, .both:
//			return isPressed ? 0.6 : 1.0
//		case .scale:
//			return 1.0
//		case .none:
//			return 1.0
//		}
//	}
//
//	// MARK: - Helper Methods
//
//	private func handleTap() {
//		if hapticFeedback {
//			UIImpactFeedbackGenerator(style: .light).impactOccurred()
//		}
//		onTap?()
//	}
//}
//
//struct PressEventsModifier: ViewModifier {
//	let onPress: () -> Void
//	let onRelease: () -> Void
//
//	func body(content: Content) -> some View {
//		content
//			.simultaneousGesture(
//				DragGesture(minimumDistance: 0)
//					.onChanged { _ in onPress() }
//					.onEnded { _ in onRelease() }
//			)
//	}
//}
//
//#Preview {
//	VStack(spacing: 20) {
//		Tappable(content: {
//			Label("Basic Button", systemImage: "square.and.arrow.up.circle.fill")
//				.foregroundStyle(.primary)
//				.padding(.vertical, 6)
//				.padding(.horizontal, 8)
//		}, onTap: {
//			print("Basic Button Clicked")
//		}, onLongPress: {
//			print("Basic Button onLongPress")
//		}, onLongPressEnd: { _ in
//			print("Basic Button onLongPress End")
//		}, cornerRadius: 6, backgroundColor: .clear, animationEffect: .scale, scaleStrength: .lg, borderColor: .black)
//
//		Button {
//			print("Basic Button Clicked")
//		} label: {
//			Text("Basic Button")
//				.foregroundStyle(.white)
//				.padding(.vertical, 6)
//				.padding(.horizontal, 8)
//				.background(Color.blue)
//				.clipShape(Capsule())
//		}
//	}
//}
