import Foundation
import Shared

private let _confirmedUsers = [
	User(
		id: "462738c5-5369-4590-818d-ac883ffa4424",
		email: "emilzulufov@gmail.com",
		username: "emil.zulufov",
		fullName: "Emil Zulufov",
		avatarUrl:
		"https://img.freepik.com/premium-photo/cartoon-character-with-blue-shirt-glasses_561641-2084.jpg?size=626&ext=jpg"
	),
	User(
		id: "a0ee0d08-cb0e-4ba6-9401-b47a2a66cdc1",
		email: "emilzulufov.commercial@gmail.com",
		username: "emo.official",
		fullName: "Emo Official",
		avatarUrl:
		"https://img.freepik.com/free-photo/3d-rendering-zoom-call-avatar_23-2149556778.jpg?size=626&ext=jpg"
	)
]

public struct PostAuthor: Codable, Identifiable, Equatable, Hashable {
	public var id: String
	public var avatarUrl: String
	public var username: String
	public var isConfirmed: Bool
	public init(
		id: String,
		avatarUrl: String,
		username: String,
		isConfirmed: Bool = false
	) {
		self.id = id
		self.avatarUrl = avatarUrl
		self.username = username
		self.isConfirmed = isConfirmed
	}

	public static var empty: PostAuthor {
		PostAuthor(id: "", avatarUrl: "", username: "")
	}

	public init(confirmed id: String, avatarUrl: String?, username: String?) {
		self.init(id: id, avatarUrl: avatarUrl ?? "", username: username ?? "", isConfirmed: true)
	}

	public init(randomConfirmed id: String? = nil, avatarUrl: String? = nil, username: String? = nil) {
		let randomConfirmedUser =
		_confirmedUsers.randomElement()!
		self.init(id: id ?? randomConfirmedUser.id, avatarUrl: avatarUrl ?? randomConfirmedUser.avatarUrl ?? "", username: username ?? randomConfirmedUser.username ?? "", isConfirmed: true)
	}

	public func encode(to encoder: any Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(self.id, forKey: .id)
		try container.encode(self.avatarUrl, forKey: .avatarUrl)
		try container.encode(self.username, forKey: .username)
		try container.encode(self.isConfirmed, forKey: .isConfirmed)
	}
	
	public init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.id = try container.decode(String.self, forKey: .id)
		self.avatarUrl = try container.decode(String.self, forKey: .avatarUrl)
		self.username = try container.decode(String.self, forKey: .username)
		self.isConfirmed = try container.decode(Bool.self, forKey: .isConfirmed)
	}
}

extension PostAuthor: DecodableWithConfiguration {
	public enum DecodingType {
		case normal
		case shared
	}

	enum SharedCodingKeys: String, CodingKey {
		case id = "sharedPostAuthorId"
		case avatarUrl = "sharedPostAuthorAvatarUrl"
		case username = "sharedPostAuthorUsername"
		case fullName = "sharedPostAuthorFullName"
		case isConfirmed = "sharedPostAuthorIsConfirmed"
	}

	enum CodingKeys: CodingKey {
		case id
		case avatarUrl
		case username
		case isConfirmed
	}

	public typealias DecodingConfiguration = DecodingType
	public init(from decoder: any Decoder, configuration: Self.DecodingConfiguration) throws {
		switch configuration {
		case .normal:
			// 正常解码
			let container = try decoder.container(keyedBy: CodingKeys.self)
			self.id = try container.decode(String.self, forKey: .id)
			self.avatarUrl = try container.decode(String.self, forKey: .avatarUrl)
			self.username = try container.decode(String.self, forKey: .username)
			self.isConfirmed = try container.decode(Bool.self, forKey: .isConfirmed)

		case .shared:
			// shared 数据解码
			let container = try decoder.container(keyedBy: SharedCodingKeys.self)
			self.id = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
			self.avatarUrl = try container.decodeIfPresent(String.self, forKey: .avatarUrl) ?? ""

			// 优先使用 username，如果没有则使用 fullName
			if let username = try container.decodeIfPresent(String.self, forKey: .username) {
				self.username = username
			} else {
				self.username = try container.decodeIfPresent(String.self, forKey: .fullName) ?? ""
			}

			self.isConfirmed = try container.decodeIfPresent(Bool.self, forKey: .isConfirmed) ?? false
		}
	}
}
