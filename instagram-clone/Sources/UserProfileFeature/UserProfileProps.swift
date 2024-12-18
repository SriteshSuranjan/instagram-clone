import Foundation
import InstaBlocks

public struct UserProfileProps: Equatable {
//	public static func == (lhs: UserProfileProps, rhs: UserProfileProps) -> Bool {
//		lhs.isSponsored == rhs.isSponsored &&
//		lhs.sponsoredBlock == rhs.sponsoredBlock &&
//		lhs.promoBlockAction?.type == rhs.promoBlockAction?.type &&
//		lhs.promoBlockAction?.actionType == rhs.promoBlockAction?.actionType
//	}
	
	public var isSponsored: Bool
	public var sponsoredBlock: PostSponsoredBlock?
	public var promoBlockAction: BlockActionWrapper?
	public init(
		isSponsored: Bool,
		sponsoredBlock: PostSponsoredBlock? = nil,
		promoBlockAction: BlockActionWrapper? = nil
	) {
		self.isSponsored = isSponsored
		self.sponsoredBlock = sponsoredBlock
		self.promoBlockAction = promoBlockAction
	}
	
	
}
