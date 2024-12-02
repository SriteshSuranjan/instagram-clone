import Foundation

public struct User: Equatable, Codable, Identifiable, Sendable {
	public let id: String
	public let email: String?
	public let username: String?
	public let fullName: String?
	public let avatarUrl: String?
	public let pushToken: String?
	public let isNewUser: Bool
	public init(
		id: String,
		email: String? = nil,
		username: String? = nil,
		fullName: String? = nil,
		avatarUrl: String? = nil,
		pushToken: String? = nil,
		isNewUser: Bool = true
	) {
		self.id = id.lowercased()
		self.email = email
		self.username = username
		self.fullName = fullName
		self.avatarUrl = avatarUrl
		self.pushToken = pushToken
		self.isNewUser = isNewUser
	}
	public static let anonymous = User(id: "")
	public var isAnonymous: Bool {
		self == .anonymous
	}
	public static func ==(lhs: User, rhs: User) -> Bool {
		lhs.id == rhs.id &&
		lhs.email == rhs.email &&
		lhs.fullName == rhs.fullName &&
		lhs.username == rhs.username &&
		lhs.avatarUrl == rhs.avatarUrl &&
		lhs.pushToken == rhs.pushToken
	}
	public static func fromAuthenticationUser(_ user: AuthenticationUser) -> User {
		User(
			id: user.id,
			email: user.email,
			username: user.username,
			fullName: user.fullName,
			avatarUrl: user.avatarUrl,
			pushToken: user.pushToken,
			isNewUser: user.isNewUser
		)
	}
	public var displayFullName: String {
		fullName ?? username ?? "Unknown"
	}
	public var displayUsername: String {
		username ?? fullName ?? "Unknown"
	}
	public var avatarName: PersonNameComponents {
		PersonNameComponents(
			givenName: fullName,
			nickname: username
		)
	}
}

