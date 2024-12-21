import AppUI
import ComposableArchitecture
import Foundation
import InstaBlocks
import InstagramBlocksUI
import Shared
import SwiftUI

public enum PostOptionType {
	case editPost
	case deletePost
	case dontShowAgainPost
	case blockPostAuthor
}

public struct PostOption: Equatable, Identifiable {
	public let id = UUID().uuidString
	public let type: PostOptionType
	public let icon: String
	public let title: String
	public let isDestructive: Bool
	public init(
		type: PostOptionType,
		icon: String,
		title: String,
		isDestructive: Bool = false
	) {
		self.type = type
		self.icon = icon
		self.title = title
		self.isDestructive = isDestructive
	}
}

@Reducer
public struct PostOptionsSheetReducer {
	public init() {}
	@ObservableState
	public struct State: Equatable {
		var optionsSettings: PostOptionsSettings
		var block: InstaBlockWrapper
		public init(
			optionsSettings: PostOptionsSettings,
			block: InstaBlockWrapper
		) {
			self.optionsSettings = optionsSettings
			self.block = block
		}

		var options: [PostOption] {
			switch optionsSettings {
			case .owner: return [
					PostOption(
						type: .editPost,
						icon: "pencil",
						title: "Edit"
					),
					PostOption(
						type: .deletePost,
						icon: "trash.fill",
						title: "Delete",
						isDestructive: true
					),
				]
			case .viewer: return [
					PostOption(
						type: .dontShowAgainPost,
						icon: "minus.circle",
						title: "Don't show again"
					),
					PostOption(
						type: .blockPostAuthor,
						icon: "slash.circle",
						title: "Block post author",
						isDestructive: true
					),
				]
			}
		}
	}

	public enum Action: BindableAction {
		case binding(BindingAction<State>)
	}

	public var body: some ReducerOf<Self> {
		BindingReducer()
		Reduce { _, action in
			switch action {
			case .binding:
				return .none
			}
		}
	}
}

public struct PostOptionsSheetView: View {
	let store: StoreOf<PostOptionsSheetReducer>
	let onTapPostOption: (PostOptionType, InstaBlockWrapper) -> Void
	@Environment(\.textTheme) var textTheme
	public init(
		store: StoreOf<PostOptionsSheetReducer>,
		onTapPostOption: @escaping (PostOptionType, InstaBlockWrapper) -> Void
	) {
		self.store = store
		self.onTapPostOption = onTapPostOption
	}

	public var body: some View {
		VStack(spacing: AppSpacing.xlg) {
			ForEach(store.options) { option in
				optionCell(option: option) {
					onTapPostOption(option.type, store.block)
				}
				.padding(.horizontal)
			}
		}
		.padding(.vertical)
	}

	@ViewBuilder
	private func optionCell(
		option: PostOption,
		action: @escaping () -> Void
	) -> some View {
		Button {
			action()
		} label: {
			HStack(spacing: AppSpacing.xlg) {
				Image(systemName: option.icon)
					.imageScale(.large)
				Text(option.title)
				Spacer()
			}
			.font(textTheme.titleMedium.font)
			.fontWeight(.semibold)
			.contentShape(.rect)
		}
		.fadeEffect()
		.foregroundStyle(option.isDestructive ? Assets.Colors.red : Assets.Colors.bodyColor)
	}
}
