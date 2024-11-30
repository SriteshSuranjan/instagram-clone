import SwiftUI
import Tagged

public struct SnackbarMessage: Equatable, Identifiable {
	public typealias ID = Tagged<SnackbarMessage, UUID>
	public let id: ID
	public let title: String
	public let description: String?
	public let icon: AppIcon?
	public let iconSize: CGFloat?
	public let iconTintColor: Color?
	public let timeout: Duration
	public let isError: Bool
	public let unDismissable: Bool
	public let isLoading: Bool
	public let backgroundColor: Color?
	public let onTap: ((ID) -> Void)?
	public init(
		id: ID = .init(UUID()),
		title: String,
		description: String? = nil,
		icon: AppIcon? = nil,
		iconSize: CGFloat? = AppSize.iconSize,
		iconTintColor: Color? = nil,
		timeout: Duration = .milliseconds(3500),
		isError: Bool = false,
		unDismissable: Bool = false,
		isLoading: Bool = false,
		backgroundColor: Color? = nil,
		onTap: ((ID) -> Void)? = nil
	) {
		self.id = id
		self.title = title
		self.description = description
		self.icon = icon
		self.iconSize = iconSize
		self.iconTintColor = iconTintColor
		self.timeout = timeout
		self.isError = isError
		self.unDismissable = unDismissable
		self.isLoading = isLoading
		self.backgroundColor = backgroundColor
		self.onTap = onTap
	}

	@MainActor public static func success(
		title: String = "Successfully!",
		description: String? = nil,
		timeout: Duration = .milliseconds(3500),
		backgroundColor: Color?
	) -> SnackbarMessage {
		SnackbarMessage(
			title: title,
			description: description,
			icon: .system("checkmark"),
			timeout: timeout,
			backgroundColor: backgroundColor
		)
	}

	@MainActor public static func error(
		title: String = "",
		description: String? = nil,
		icon: AppIcon? = nil,
		timeout: Duration = .milliseconds(3500),
		backgroundColor: Color?
	) -> SnackbarMessage {
		SnackbarMessage(
			title: title,
			description: description,
			icon: icon ?? .system("xmark"),
			timeout: timeout,
			isError: true,
			backgroundColor: backgroundColor
		)
	}

	@MainActor public static func loading(
		title: String = "Loading...",
		timeout: Duration = .milliseconds(3500)
	) -> SnackbarMessage {
		SnackbarMessage(
			title: title,
			timeout: timeout,
			isLoading: true
		)
	}

	public static func ==(lhs: SnackbarMessage, rhs: SnackbarMessage) -> Bool {
		lhs.id == rhs.id
	}
}
