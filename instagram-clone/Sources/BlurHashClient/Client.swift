import Foundation
import DependenciesMacros
import UIKit

@DependencyClient
public struct BlurHashClient: Sendable {
	public var encode: @Sendable (Data) async -> String?
	public var decode: @Sendable (String) async -> UIImage?
}
