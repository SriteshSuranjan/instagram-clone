import Foundation
import UIKit
import Dependencies
import UnifiedBlurHash

extension BlurHashClient: DependencyKey {
	public static let liveValue = BlurHashClient(
		encode: { image in
			await UnifiedBlurHash.getBlurHashString(from: image)
		},
		decode: { hashString in
			await UnifiedBlurHash.getUnifiedImage(from: hashString)
		}
	)
}
