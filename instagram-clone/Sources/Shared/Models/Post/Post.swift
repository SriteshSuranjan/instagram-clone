import Foundation

public struct Post: Equatable, Identifiable, Codable {
	public var id: String
	public var author: User
	public var caption: String
	public var createdAt: Date
	public var updatedAt: Date?
	public var media: [MediaItem]
	public init(
		id: String,
		author: User,
		caption: String,
		createdAt: Date,
		updatedAt: Date? = nil,
		media: [MediaItem]
	) {
		self.id = id
		self.author = author
		self.caption = caption
		self.createdAt = createdAt
		self.updatedAt = updatedAt
		self.media = media
	}
}

extension Post {
	private enum CodingKeys: String, CodingKey {
		case id
		case author
		case caption
		case createdAt = "created_at"
		case upadtedAt = "updated_at"
		case media
		
		case userId = "user_id"
		case avatarUrl = "avatar_url"
		case username
		case fullName = "full_name"
	}
	
	public init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		id = try container.decode(String.self, forKey: .id)
		caption = try container.decode(String.self, forKey: .caption)
		createdAt = try container.decode(Date.self, forKey: .createdAt)
		updatedAt = try container.decodeIfPresent(Date.self, forKey: .upadtedAt)
		let mediaJsonString = try container.decode(String.self, forKey: .media)
		media = try ListMediaConverter.fromJson(mediaJsonString)
		if let author = try? container.decode(User.self, forKey: .author) {
			self.author = author
		} else {
			let userId = try container.decode(String.self, forKey: .userId)
			let avatarUrl = try container.decode(String.self, forKey: .avatarUrl)
			let username = try container.decodeIfPresent(String.self, forKey: .username) ?? (try container.decode(String.self, forKey: .fullName))
			self.author = User(id: userId, username: username, avatarUrl: avatarUrl)
		}
	}
	
	public func encode(to encoder: any Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(id, forKey: .id)
		try container.encode(author, forKey: .author)
		try container.encode(caption, forKey: .caption)
		try container.encode(createdAt, forKey: .createdAt)
		try container.encodeIfPresent(updatedAt, forKey: .upadtedAt)
		let mediaJsonString = try ListMediaConverter.toJson(media)
		try container.encode(mediaJsonString, forKey: .media)
	}
}
