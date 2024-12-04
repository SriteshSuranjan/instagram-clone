import Foundation

public struct SelectedImageDetails: Equatable {
	public let selectedFiles: [SelectedByte]
	public let aspectRatio: Double
	public let multiSelectionMode: Bool
	public init(selectedFiles: [SelectedByte], aspectRatio: Double, multiSelectionMode: Bool) {
		self.selectedFiles = selectedFiles
		self.aspectRatio = aspectRatio
		self.multiSelectionMode = multiSelectionMode
	}
}

public struct SelectedByte: Equatable {
	public let selectedFile: URL
	public let selectedData: Data
	public let isImage: Bool
	public init(selectedFile: URL, selectedData: Data, isImage: Bool) {
		self.selectedFile = selectedFile
		self.selectedData = selectedData
		self.isImage = isImage
	}
}
