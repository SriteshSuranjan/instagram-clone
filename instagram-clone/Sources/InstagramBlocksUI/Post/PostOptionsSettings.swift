import Foundation
import InstaBlocks

public enum PostOptionsSettings {
	case owner(onPostDelete: (String) -> Void, onPostEdit: (any PostBlock) -> Void)
	case viewer
}

