import Foundation
import SwiftUI
import ComposableArchitecture
import AppUI
import YPImagePicker

@Reducer
public struct CreatePostReducer {
	public init() {}
	@ObservableState
	public struct State: Equatable {
		public init() {}
	}
	public enum Action: BindableAction {
		case binding(BindingAction<State>)
	}
	public var body: some ReducerOf<Self> {
		BindingReducer()
		Reduce { state, action in
			switch action {
			case .binding:
				return .none
			}
		}
	}
}

public struct CreatePostView: View {
	let store: StoreOf<CreatePostReducer>
	
//	@State private var selectedItems: [YPMediaItem] = []
	@State private var selectedVideo: URL?
	@State private var selectedImage: UIImage?
	public init(store: StoreOf<CreatePostReducer>) {
		self.store = store
	}
	public var body: some View {
		Text("Create Post")
	}
}
