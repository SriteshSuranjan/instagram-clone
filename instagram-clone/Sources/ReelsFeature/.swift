import Foundation
import SwiftUI
import Shared
import InstagramBlocksUI
import InstaBlocks
import VideoPlayer
import Kingfisher
import ComposableArchitecture

@Reducer
public struct ReelReducer {
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
				
			}
		}
	}
}

public struct ReelView: View {
	let store: StoreOf<ReelReducer>
	public init(store: StoreOf<ReelReducer>) {
		self.store = store
	}
	public var body: some View {
		/*@START_MENU_TOKEN@*//*@PLACEHOLDER=Hello, world!@*/Text("Hello, world!")/*@END_MENU_TOKEN@*/
	}
}
