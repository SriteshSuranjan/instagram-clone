import SwiftUI
import AppUI

public enum AuthProvider: CustomStringConvertible, Sendable {
	case google
	case github
	
	public var description: String {
		switch self {
		case .google: return "Sign In with Google"
		case .github: return "Sign In with Github"
		}
	}
}

public struct AuthProviderSignInButton: View {
	let provider: AuthProvider
	let isLoading: Bool
	let action: () -> Void
	@Environment(\.textTheme) var textTheme
	public init(provider: AuthProvider, isLoading: Bool, action: @escaping () -> Void) {
		self.provider = provider
		self.isLoading = isLoading
		self.action = action
	}
	public var authIconView: some View {
		switch provider {
		case .google: return Assets.Icons.google.view(width: 24, height: 24, renderMode: .original)
		case .github: return Assets.Icons.github.view(width: 24, height: 24, renderMode: .original)
		}
	}
	public var body: some View {
		Button(action: action) {
			HStack(spacing: AppSpacing.sm) {
				if isLoading {
					ProgressView()
						.progressViewStyle(.circular)
						.tint(Assets.Colors.bodyColor)
						.padding(.vertical, AppSpacing.sm)
				} else {
					authIconView
					Text(provider.description)
						.font(textTheme.labelLarge.font)
						.foregroundStyle(Assets.Colors.bodyColor)
				}
			}
			.frame(height: 44)
			.frame(maxWidth: .infinity)
			.background(RoundedRectangle(cornerRadius: 4).fill(Assets.Colors.focusColor))
		}
		.scaleEffect(config: ButtonAnimationConfig(scale: 0.95))
	}
}
