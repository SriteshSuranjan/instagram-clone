import Foundation
import UIKit
import Dependencies
import UnifiedBlurHash

extension BlurHashClient: DependencyKey {
	public static let liveValue = BlurHashClient(
		encode: { data in
			guard let image = UIImage(data: data) else {
				return nil
			}
			return await UnifiedBlurHash.getBlurHashString(from: image)
		},
		decode: { hashString in
			await UnifiedBlurHash.getUnifiedImage(from: hashString)
		}
	)
}
