import Foundation

// public enum PostOptionsSettings: Equatable {
//	public static func == (lhs: PostOptionsSettings, rhs: PostOptionsSettings) -> Bool {
//		switch (lhs, rhs) {
//		case (.viewer, .viewer):
//			return true
//		case (.owner, .owner):
//			return true
//		default: return false
//		}
//	}
//
//	case owner(onPostDelete: (String) -> Void, onPostEdit: (InstaBlockWrapper) -> Void)
//	case viewer(onPostNotShowAgain: (String) -> Void, onPostBlockAuthor: (InstaBlockWrapper) -> Void)
// }

public enum PostOptionsSettings: Equatable {
	case owner
	case viewer
}
