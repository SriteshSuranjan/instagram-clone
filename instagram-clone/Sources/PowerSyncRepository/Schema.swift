@preconcurrency import PowerSync

extension Schema {
	static let appSchema: Schema = {
		Schema(
			tables: [
				Table(
					name: "profiles",
					columns: [
						Column(name: "full_name", type: .text),
						Column(name: "email", type: .text),
						Column(name: "username", type: .text),
						Column(name: "avatar_url", type: .text),
						Column(name: "push_token", type: .text),
					],
					indexes: [],
					localOnly: false,
					insertOnly: false,
					viewNameOverride: "profiles"
				),
				Table(
					name: "posts",
					columns: [
						Column(name: "user_id", type: .text),
						Column(name: "created_at", type: .text),
						Column(name: "caption", type: .text),
						Column(name: "updated_at", type: .text),
						Column(name: "media", type: .text),
					],
					indexes: [
						Index(
							name: "user",
							columns: [IndexedColumn(column: "user_id", ascending: true, columnDefinition: nil, type: nil)]
						),
					],
					localOnly: false,
					insertOnly: false,
					viewNameOverride: "users"
				),
				Table(
					name: "videos",
					columns: [
						Column(name: "owner_id", type: .text),
						Column(name: "url", type: .text),
						Column(name: "blur_hash", type: .text),
						Column(name: "first_frame_url", type: .text),
					],
					indexes: [
						Index(name: "user", columns: [IndexedColumn(column: "owner_id", ascending: true, columnDefinition: nil, type: nil)]),
					],
					localOnly: false,
					insertOnly: false,
					viewNameOverride: "videos"
				),
				Table(
					name: "images",
					columns: [
						Column(name: "owner_id", type: .text),
						Column(name: "url", type: .text),
						Column(name: "blur_hash", type: .text),
					],
					indexes: [
						Index(
							name: "user",
							columns: [
								IndexedColumn(column: "owner_id", ascending: true, columnDefinition: nil, type: nil),
							]
						),
					],
					localOnly: false,
					insertOnly: false,
					viewNameOverride: "images"
				),
				Table(
					name: "likes",
					columns: [
						Column(name: "user_id", type: .text),
						Column(name: "comment_id", type: .text),
						Column(name: "post_id", type: .text),
					],
					indexes: [
						Index(name: "user", columns: [IndexedColumn(column: "user_id", ascending: true, columnDefinition: nil, type: nil)]),
						Index(name: "post", columns: [IndexedColumn(column: "post_id", ascending: true, columnDefinition: nil, type: nil)]),
						Index(name: "comment", columns: [IndexedColumn(column: "comment_id", ascending: true, columnDefinition: nil, type: nil)]),
					],
					localOnly: false,
					insertOnly: false,
					viewNameOverride: "likes"
				),
				Table(
					name: "comments",
					columns: [
						Column(name: "post_id", type: .text),
						Column(name: "user_id", type: .text),
						Column(name: "content", type: .text),
						Column(name: "created_at", type: .text),
						Column(name: "replied_to_comment_id", type: .text),
					],
					indexes: [
						Index(name: "user", columns: [IndexedColumn(column: "user_id", ascending: true, columnDefinition: nil, type: nil)]),
						Index(name: "post", columns: [IndexedColumn(column: "post_id", ascending: true, columnDefinition: nil, type: nil)]),
						Index(name: "comment", columns: [IndexedColumn(column: "replied_to_comment_id", ascending: true, columnDefinition: nil, type: nil)]),
					],
					localOnly: false,
					insertOnly: false,
					viewNameOverride: "comments"
				),
				Table(
					name: "conversations",
					columns: [
						Column(name: "type", type: .text),
						Column(name: "name", type: .text),
						Column(name: "created_at", type: .text),
						Column(name: "updated_at", type: .text),
					],
					indexes: [],
					localOnly: false,
					insertOnly: false,
					viewNameOverride: "conversations"
				),
				Table(
					name: "participants",
					columns: [
						Column(name: "user_id", type: .text),
						Column(name: "conversation_id", type: .text),
					],
					indexes: [
						Index(name: "conversation", columns: [IndexedColumn(column: "conversation_id", ascending: true, columnDefinition: nil, type: nil)]),
						Index(name: "user", columns: [IndexedColumn(column: "user_id", ascending: true, columnDefinition: nil, type: nil)]),
					],
					localOnly: false,
					insertOnly: false,
					viewNameOverride: "participants"
				),
				Table(
					name: "messages",
					columns: [
						Column(name: "conversation_id", type: .text),
						Column(name: "from_id", type: .text),
						Column(name: "type", type: .text),
						Column(name: "message", type: .text),
						Column(name: "reply_message_id", type: .text),
						Column(name: "created_at", type: .text),
						Column(name: "updated_at", type: .text),
						Column(name: "is_read", type: .integer),
						Column(name: "is_edited", type: .integer),
						Column(name: "is_deleted", type: .integer),
						Column(name: "reply_message_username", type: .text),
						Column(name: "reply_message_attachment_url", type: .text),
						Column(name: "shared_post_id", type: .text),
					],
					indexes: [
						Index(name: "conversation", columns: [IndexedColumn(column: "conversation_id", ascending: true, columnDefinition: nil, type: nil)]),
						Index(name: "user", columns: [IndexedColumn(column: "from_id", ascending: true, columnDefinition: nil, type: nil)]),
						Index(name: "message", columns: [IndexedColumn(column: "reply_message_id", ascending: true, columnDefinition: nil, type: nil)]),
						Index(name: "post", columns: [IndexedColumn(column: "shared_post_id", ascending: true, columnDefinition: nil, type: nil)]),
					],
					localOnly: false,
					insertOnly: false,
					viewNameOverride: "messages"
				),
				Table(
					name: "attachments",
					columns: [
						Column(name: "message_id", type: .text),
						Column(name: "title", type: .text),
						Column(name: "text", type: .text),
						Column(name: "title_link", type: .text),
						Column(name: "image_url", type: .text),
						Column(name: "thumb_url", type: .text),
						Column(name: "author_name", type: .text),
						Column(name: "author_link", type: .text),
						Column(name: "asset_url", type: .text),
						Column(name: "og_scrape_url", type: .text),
						Column(name: "type", type: .text),
					],
					indexes: [
						Index(name: "message", columns: [IndexedColumn(column: "message_id", ascending: true, columnDefinition: nil, type: nil)]),
					],
					localOnly: false,
					insertOnly: false,
					viewNameOverride: "attachments"
				),
				Table(
					name: "subscriptions",
					columns: [
						Column(name: "subscriber_id", type: .text),
						Column(name: "subscribed_to_id", type: .text),
					],
					indexes: [
						Index(
							name: "user",
							columns: [
								IndexedColumn(column: "subscriber_id", ascending: true, columnDefinition: nil, type: nil),
								IndexedColumn(column: "subscribed_to_id", ascending: true, columnDefinition: nil, type: nil),
							]
						),
					],
					localOnly: false,
					insertOnly: false,
					viewNameOverride: "subscriptions"
				),
				Table(
					name: "stories",
					columns: [
						Column(name: "user_id", type: .text),
						Column(name: "content_type", type: .text),
						Column(name: "content_url", type: .text),
						Column(name: "duration", type: .integer),
						Column(name: "created_at", type: .text),
						Column(name: "expires_at", type: .text),
					],
					indexes: [
						Index(name: "user", columns: [IndexedColumn(column: "user_id", ascending: true, columnDefinition: nil, type: nil)]),
					],
					localOnly: false,
					insertOnly: false,
					viewNameOverride: "stories"
				),
			]
		)
	}()
}

