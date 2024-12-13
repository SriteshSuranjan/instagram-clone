import Foundation
@testable import InstaBlocks
import Testing

let decoder: JSONDecoder = {
	let jsonDecoder = JSONDecoder()
	jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
	return jsonDecoder
}()

@Test func postAuthorDecode() async throws {
	let jsonString = #"{"shared_post_author_id": "1234567", "shared_post_author_username": "PostAuthor", "shared_post_author_full_name": "PostAuthorFullName", "shared_post_author_is_confirmed": true}"#
	
	let postAuthor = try decoder.decode(PostAuthor.self, from: jsonString.data(using: .utf8)!, configuration: .shared)
	debugPrint(postAuthor)
}

@Test func blockAction() async throws {
	let jsonString = #"[{"author_id": "123456", "actionType": "navigation", "type": "__navigate_to_author__"}, {"type": "__unknown__"}, {"author_id": "1234567", "promo_preview_image_url": "https://google.com", "promo_url": "https://google.com", "type": "__navigate_to_sponsored_author__", "action_type": "navigation"}]"#
	let blockAction: [BlockActionWrapper] = try decoder.decode([BlockActionWrapper].self, from: jsonString.data(using: .utf8)!)
	debugPrint(blockAction)
}
