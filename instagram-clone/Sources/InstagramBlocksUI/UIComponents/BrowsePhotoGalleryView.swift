import SwiftUI
import Photos

public struct BrowsePhotoGalleryView: View {
	public var body: some View {
		GeometryReader { geometryReader in
			VStack {
				VStack {
					Rectangle()
						.fill(.red)
						.frame(height: (geometryReader.size.height - 140) / 2)
					
					HStack {
						Label("Recents", systemImage: "chevron.down")
							.labelStyle(.titleAndIcon)
							.font(.subheadline)
							.fontWeight(.semibold)
							.foregroundStyle(.white)
					}
				}
			}
			.navigationBarTitle("New Post", displayMode: .inline)
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button {
						
					} label: {
						Image(systemName: "xmark")
							.foregroundStyle(.white)
					}
				}
				ToolbarItem(placement: .primaryAction) {
					Button {
						
					} label: {
						Text("Next")
							.font(.headline)
							.foregroundStyle(.primary)
					}
				}
			}
		}
		.colorScheme(.dark)
	}
}

#Preview {
	NavigationStack {
		BrowsePhotoGalleryView()
	}
}
