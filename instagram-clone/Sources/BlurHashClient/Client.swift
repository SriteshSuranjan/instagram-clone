import Foundation
import UIKit
import DependenciesMacros
import UnifiedBlurHash

@DependencyClient
public struct BlurHashClient: Sendable {
	public var encode: @Sendable (UIImage) async -> String?
	public var decode: @Sendable (String) async -> UnifiedImage?
}
