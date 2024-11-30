import ComposableArchitecture
import Foundation
import SwiftUI
import Tagged
import Shared

public struct AppSnackbarView: View {
	@Environment(\.textTheme) var textTheme
	@Binding var snackbarMessages: [SnackbarMessage]
	public init(snackbarMessages: Binding<[SnackbarMessage]>) {
		self._snackbarMessages = snackbarMessages
	}

	public var body: some View {
		ZStack {
			ForEach(snackbarMessages) { message in
				snackBarMessageButton(message) {
					withAnimation(.bouncy) {
						snackbarMessages.removeAll(where: { $0 == message })
					}
				}
			}
		}
		.transition(.snackbarInsertionAndRemoval)
	}

	@ViewBuilder
	private func snackBarMessageButton(_ message: SnackbarMessage, onDismiss: @escaping () -> Void) -> some View {
		Button {
			if let onTap = message.onTap {
				onTap(message.id)
				onDismiss()
			}
		} label: {
			HStack(spacing: AppSpacing.md - AppSpacing.xxs) {
				if let icon = message.icon {
					icon.image
						.scaledToFit()
						.imageScale(.large)
						.fontWeight(.bold)
						.frame(width: message.iconSize ?? AppSize.iconSizeSmall, height: message.iconSize ?? AppSize.iconSizeSmall)
				}
				if message.isLoading {
					ProgressView()
						.progressViewStyle(.circular)
						.scaleEffect(1)
						.tint(.white)
				}
				VStack(alignment: .leading) {
					Text(message.title)
						.font(textTheme.titleMedium.font)
						.foregroundStyle(.white)
						.lineLimit(3)
					if let description = message.description {
						Text(description)
							.font(textTheme.titleSmall.font)
							.lineLimit(3)
					}
				}
			}
			.padding(.horizontal, AppSpacing.md)
		}
		.task {
			try? await Task.sleep(for: message.timeout)
			onDismiss()
		}
		.buttonStyle(
			FilledAppButtonStyle(
				style: AppButtonStyle(
					foregroundColor: .white,
					backgroundColor: message.backgroundColor,
					cornerRadius: 13,
					padding: EdgeInsets(
						top: AppSpacing.sm,
						leading: AppSpacing.md,
						bottom: AppSpacing.sm,
						trailing: AppSpacing.md
					),
					fullWidth: true
				)
			)
		)
		.offset(y: 10)
		.shadow(color: .black.opacity(0.1), radius: 15, x: 0, y: 2)
		.transition(.snackbarInsertionAndRemoval)
	}
}

public extension View {
	func snackbar(messages: Binding<[SnackbarMessage]>) -> some View {
		modifier(SnackbarModifier(snackbarMessages: messages))
	}
}

public struct SnackbarModifier: ViewModifier {
	@Binding var snackbarMessages: [SnackbarMessage]
	public func body(content: Content) -> some View {
		ZStack(alignment: .top) {
			content
			if !snackbarMessages.isEmpty {
				AppSnackbarView(snackbarMessages: $snackbarMessages)
			}
		}
	}
}

extension AnyTransition {
	static var snackbarInsertionAndRemoval: AnyTransition {
		.asymmetric(
			insertion: .offset(y: -50).combined(with: .opacity),
			removal: .offset(y: -50).combined(with: .opacity)
		)
	}
}
