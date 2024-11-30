import AppUI
import ComposableArchitecture
import Foundation
import PhotosUI
import SwiftUI

@MainActor
public struct AvatarImagePicker: View {
	let compress: Bool
	let radius: CGFloat
	let addButtonRadius: CGFloat
	let placeholderSize: CGFloat
	let withPlaceholder: Bool
	let onUpload: ((Data, URL) -> Void)?
	@Environment(\.colorScheme) var colorScheme
	@State private var selectedPhotoPickerItem: PhotosPickerItem?
	@State private var selectedAvatarImage: Image?
	public init(
		compress: Bool = true,
		radius: CGFloat = 64,
		addButtonRadius: CGFloat = 18,
		placeholderSize: CGFloat = 54,
		withPlaceholder: Bool = true,
		onUpload: ((Data, URL) -> Void)?
	) {
		self.compress = compress
		self.radius = radius
		self.addButtonRadius = addButtonRadius
		self.placeholderSize = placeholderSize
		self.withPlaceholder = withPlaceholder
		self.onUpload = onUpload
	}

	public var body: some View {
		Button {} label: {
			ZStack(alignment: .bottomTrailing) {
				PhotosPicker(
					selection: $selectedPhotoPickerItem,
					matching: .all(of: [.images]),
					photoLibrary: .shared()
				) {
					avatarContent()
				}
				Circle()
					.fill(Assets.Colors.blue)
					.frame(width: addButtonRadius * 2, height: addButtonRadius * 2)
					.overlay {
						Image(systemName: "plus")
							.imageScale(.small)
					}
					.overlay {
						Circle()
							.stroke(Assets.Colors.customReversedAdaptiveColor(colorScheme), lineWidth: 2)
					}
			}
		}
		.fadeEffect()
		.task(id: selectedPhotoPickerItem) {
			let pickerItemData = try? await selectedPhotoPickerItem?.loadTransferable(type: Data.self)
			if let pickerItemData,
			   let uiImage = UIImage(data: pickerItemData)
			{
				await MainActor.run {
					selectedAvatarImage = Image(uiImage: uiImage)
				}
			}
		}
	}

	@ViewBuilder
	@MainActor
	private func avatarContent() -> some View {
		Group {
			if let selectedAvatarImage {
				selectedAvatarImage
					.resizable()
					.scaledToFill()
					.clipShape(Circle())
			} else {
				Circle()
					.fill(Color.MaterialGray.shade500)
					.overlay {
						Image(systemName: "person.fill")
							.resizable()
							.imageScale(.large)
							.foregroundStyle(Assets.Colors.bodyColor)
							.frame(width: radius, height: radius)
					}
			}
		}
		.frame(width: radius * 2, height: radius * 2)
	}
}
