import Foundation

public let encoder: JSONEncoder = {
	let encoder = JSONEncoder()
	encoder.dateEncodingStrategy = .iso8601
	encoder.keyEncodingStrategy = .convertToSnakeCase
	return encoder
}()

public let decoder: JSONDecoder = {
	let decoder = JSONDecoder()
	decoder.dateDecodingStrategy = .iso8601
	decoder.keyDecodingStrategy = .convertFromSnakeCase
	return decoder
}()

enum ListMediaConverter {
	static func fromJson(_ jsonString: String) throws -> [MediaItem] {
		guard let data = jsonString.data(using: .utf8) else {
			throw MediaConverterError.invalidJsonString
		}
		return try decoder.decode([MediaItem].self, from: data)
	}

	static func toJson(_ media: [MediaItem]) throws -> String {
		let data = try encoder.encode(media)
		guard let jsonString = String(data: data, encoding: .utf8) else {
			throw MediaConverterError.encodingFailed
		}
		return jsonString
	}
}

enum MediaConverterError: Error {
	case invalidJsonString
	case encodingFailed
}
