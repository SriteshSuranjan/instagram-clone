import AppUI
import AVFoundation
import AVKit
import BottomBarVisiblePreference
import ComposableArchitecture
import CreatePostFeature
import Foundation
import Photos
import Shared
import SwiftUI
import UIKit
import YPImagePicker

public struct MediaPickerView: UIViewControllerRepresentable {
	// 配置选项
	public struct Configuration: Equatable {
		var maxItems: Int
		var reels: Bool
		var showVideo: Bool
		var showsCrop: Bool
		var cropRatio: Double
		var startOnScreen: YPPickerScreen
		var showsFilters: Bool
		var showVideoTrim: Bool
		var shouldSaveToAlbum: Bool
		public init(maxItems: Int = 1,
		            reels: Bool = true,
								showVideo: Bool = true,
		            showsCrop: Bool = false,
		            cropRatio: Double = 1.0,
		            startOnScreen: YPPickerScreen = .library,
		            showsFilters: Bool = false,
		            showVideoTrim: Bool = false,
		            shouldSaveToAlbum: Bool = false)
		{
			self.maxItems = maxItems
			self.reels = reels
			self.showVideo = showVideo
			self.showsCrop = showsCrop
			self.cropRatio = cropRatio
			self.startOnScreen = startOnScreen
			self.showsFilters = showsFilters
			self.showVideoTrim = showVideoTrim
			self.shouldSaveToAlbum = shouldSaveToAlbum
		}
	}

	// 回调闭包
	let configuration: Configuration
	let onCompletion: ([YPMediaItem], Bool) -> Void

	public init(configuration: Configuration = Configuration(),
	            onCompletion: @escaping ([YPMediaItem], Bool) -> Void)
	{
		self.configuration = configuration
		self.onCompletion = onCompletion
	}

	public func makeUIViewController(context: Context) -> YPImagePicker {
		var config = YPImagePickerConfiguration()

		// 基础配置
		config.library.maxNumberOfItems = configuration.maxItems
		config.startOnScreen = configuration.startOnScreen
		config.shouldSaveNewPicturesToAlbum = configuration.shouldSaveToAlbum
		config.showsPhotoFilters = configuration.showsFilters
		config.showsVideoTrimmer = configuration.showVideoTrim

		// 设置支持的媒体类型
		config.library.mediaType = configuration.reels ? .video : (configuration.showVideo ? .photoAndVideo : .photo)
		config.screens = configuration.reels ? [.library, .video] : (configuration.showVideo ? [.library, .photo, .video] : [.library, .photo])

		// 裁剪设置
		if configuration.showsCrop {
			config.showsCrop = .rectangle(ratio: configuration.cropRatio)
		}

		// 其他常用配置
		config.library.itemOverlayType = .grid
		config.hidesStatusBar = false
		config.hidesBottomBar = false
		config.video.compression = AVAssetExportPresetMediumQuality
		config.video.libraryTimeLimit = 500.0
		config.library.skipSelectionsGallery = true

		let picker = YPImagePicker(configuration: config)
		picker.didFinishPicking { items, cancelled in
			onCompletion(items, cancelled)
		}

		return picker
	}

	public func updateUIViewController(_ uiViewController: YPImagePicker, context: Context) {
		// 更新逻辑（如果需要）
	}
}

extension YPMediaItem: @retroactive Equatable {
	public static func ==(lhs: YPMediaItem, rhs: YPMediaItem) -> Bool {
		switch (lhs, rhs) {
		case (let .photo(lhsPhoto), .photo(let rhsPhoto)):
			return lhsPhoto.asset == rhsPhoto.asset
		case (let .video(lhsVideo), .video(let rhsVideo)):
			return lhsVideo.asset == rhsVideo.asset
		default: return false
		}
	}
}

public enum MediaPickerNextAction: Equatable {
	case uploadAvatar
	case createPost
}

@Reducer
public struct MediaPickerReducer {
	public init() {}

	@ObservableState
	public struct State: Equatable {
		var pickerConfiguration: MediaPickerView.Configuration
		var nextAction: MediaPickerNextAction
		@Presents var createPost: CreatePostReducer.State?
		public init(
			pickerConfiguration: MediaPickerView.Configuration,
			nextAction: MediaPickerNextAction = .createPost
		) {
			self.pickerConfiguration = pickerConfiguration
			self.nextAction = nextAction
		}
	}

	public enum Action: BindableAction {
		case binding(BindingAction<State>)
		case onTapNextButton([YPMediaItem])
		case onTapCancelButton
		case createPost(PresentationAction<CreatePostReducer.Action>)
		case delegate(Delegate)
		public enum Delegate {
			case createPostPopToRoot
			case avatarNextAction(imageData: Data)
			case onTapCancelButton
		}
	}

	@Dependency(\.dismiss) var dismiss

	public var body: some ReducerOf<Self> {
		BindingReducer()
		Reduce { state, action in
			switch action {
			case .binding:
				return .none
			case .delegate:
				return .none
			case .onTapNextButton(let items):
				switch state.nextAction {
				case .uploadAvatar:
					guard case let .photo(photo) = items.first,
					let imageData = photo.image.pngData() else {
						return .none
					}
					return .run { send in
						await send(.delegate(.avatarNextAction(imageData: imageData)))
						@Dependency(\.dismiss) var dismiss
						await dismiss()
					}
				case .createPost:
					let selectedImageDetails = SelectedImageDetails(selectedFiles: items.map(SelectedByte.selectedByte(with:)), aspectRatio: 1.0, multiSelectionMode: true)
					state.createPost = CreatePostReducer.State(selectedImageDetails: selectedImageDetails)
					return .none
				}
				
			case .onTapCancelButton:
				return .send(.delegate(.onTapCancelButton), animation: .default)
			case .createPost(.presented(.delegate(.popToRoot))):
				state.createPost = nil
				return .send(.delegate(.createPostPopToRoot))
			case .createPost:
				return .none
			}
		}
		.ifLet(\.$createPost, action: \.createPost) {
			CreatePostReducer()
		}
	}
}

extension SelectedByte {
	static func selectedByte(with item: YPMediaItem) -> SelectedByte {
		switch item {
		case .photo(let p):
			return SelectedByte(
				selectedFile: p.url ?? URL(string: "nil://placeholder")!,
				selectedData: p.image.jpegData(compressionQuality: 0.7) ?? Data(),
				isImage: true
			)
		case .video(let v):
			return SelectedByte(
				selectedFile: v.url,
				selectedData: v.thumbnail.pngData() ?? Data(),
				isImage: false
			)
		}
	}
}

public struct MediaPicker: View {
	@Bindable var store: StoreOf<MediaPickerReducer>
	public init(store: StoreOf<MediaPickerReducer>) {
		self.store = store
	}

	public var body: some View {
		MediaPickerView(configuration: store.pickerConfiguration) { items, cancelled in
			guard !cancelled else {
				store.send(.onTapCancelButton)
				return
			}
			store.send(.onTapNextButton(items))
		}
		.toolbar(.hidden, for: .navigationBar)
		.navigationDestination(
			item: $store.scope(
				state: \.createPost,
				action: \.createPost
			)
		) { createPostStore in
			CreatePostView(store: createPostStore)
		}
	}
}

public struct YPImagePickerView: UIViewControllerRepresentable {
	@Binding var selectedItems: [YPMediaItem]
	@Binding var selectedImage: UIImage?
	@Environment(\.presentationMode) var presentationMode

	public init(selectedItems: Binding<[YPMediaItem]>,
	            selectedImage: Binding<UIImage?>,
	            configureYPImagePicker: ((YPImagePickerConfiguration) -> YPImagePickerConfiguration)? = nil)
	{
		self._selectedItems = selectedItems
		self._selectedImage = selectedImage
		self.configureYPImagePicker = configureYPImagePicker
	}

	// 配置回调，让使用者可以自定义配置
	var configureYPImagePicker: ((YPImagePickerConfiguration) -> YPImagePickerConfiguration)?

	public func makeUIViewController(context: Context) -> ExampleViewController {
		let viewController = ExampleViewController()
		viewController.selectedItems = selectedItems
		return viewController
	}

	public func updateUIViewController(_ uiViewController: ExampleViewController, context: Context) {
		uiViewController.selectedItems = selectedItems
		if let image = selectedImage {
			uiViewController.selectedImageV.image = image
		}
	}

	public func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}

	public class Coordinator: NSObject, YPImagePickerDelegate {
		let parent: YPImagePickerView

		init(_ parent: YPImagePickerView) {
			self.parent = parent
		}

		public func imagePickerHasNoItemsInLibrary(_ picker: YPImagePicker) {
			// 处理空库情况
		}

		public func shouldAddToSelection(indexPath: IndexPath, numSelections: Int) -> Bool {
			return true
		}
	}
}

public class ExampleViewController: UIViewController {
	var selectedItems = [YPMediaItem]()

	lazy var selectedImageV: UIImageView = {
		let imageView = UIImageView(frame: CGRect(x: 0,
		                                          y: 0,
		                                          width: UIScreen.main.bounds.width,
		                                          height: UIScreen.main.bounds.height * 0.45))
		imageView.contentMode = .scaleAspectFit
		return imageView
	}()

	lazy var pickButton: UIButton = {
		let button = UIButton(frame: CGRect(x: 0,
		                                    y: 0,
		                                    width: 100,
		                                    height: 100))
		button.setTitle("Pick", for: .normal)
		button.setTitleColor(.black, for: .normal)
		button.addTarget(self, action: #selector(showPicker), for: .touchUpInside)
		return button
	}()

	lazy var resultsButton: UIButton = {
		let button = UIButton(frame: CGRect(x: 0,
		                                    y: UIScreen.main.bounds.height - 100,
		                                    width: UIScreen.main.bounds.width,
		                                    height: 100))
		button.setTitle("Show selected", for: .normal)
		button.setTitleColor(.black, for: .normal)
		button.addTarget(self, action: #selector(showResults), for: .touchUpInside)
		return button
	}()

	override public func viewDidLoad() {
		super.viewDidLoad()

		view.backgroundColor = .white
		view.addSubview(selectedImageV)
		view.addSubview(pickButton)
		pickButton.center = view.center
		view.addSubview(resultsButton)
	}

	@objc
	func showResults() {
		if !selectedItems.isEmpty {
			let gallery = YPSelectionsGalleryVC(items: selectedItems) { g, _ in
				g.dismiss(animated: true, completion: nil)
			}
			let navC = UINavigationController(rootViewController: gallery)
			present(navC, animated: true, completion: nil)
		} else {
			print("No items selected yet.")
		}
	}

	// MARK: - Configuration

	@objc
	func showPicker() {
		var config = YPImagePickerConfiguration()

		/* Uncomment and play around with the configuration 👨‍🔬 🚀 */

		/* Set this to true if you want to force the  library output to be a squared image. Defaults to false */
		// config.library.onlySquare = true

		/* Set this to true if you want to force the camera output to be a squared image. Defaults to true */
		// config.onlySquareImagesFromCamera = false

		/* Ex: cappedTo:1024 will make sure images from the library or the camera will be
		 resized to fit in a 1024x1024 box. Defaults to original image size. */
		// config.targetImageSize = .cappedTo(size: 1024)

		/* Choose what media types are available in the library. Defaults to `.photo` */
		config.library.mediaType = .photoAndVideo
		config.library.itemOverlayType = .grid
		/* Enables selecting the front camera by default, useful for avatars. Defaults to false */
		// config.usesFrontCamera = true

		/* Adds a Filter step in the photo taking process. Defaults to true */
		// config.showsFilters = false

		/* Manage filters by yourself */
		// config.filters = [YPFilter(name: "Mono", coreImageFilterName: "CIPhotoEffectMono"),
		//                   YPFilter(name: "Normal", coreImageFilterName: "")]
		// config.filters.remove(at: 1)
		// config.filters.insert(YPFilter(name: "Blur", coreImageFilterName: "CIBoxBlur"), at: 1)

		/* Enables you to opt out from saving new (or old but filtered) images to the
		 user's photo library. Defaults to true. */
		config.shouldSaveNewPicturesToAlbum = false

		/* Choose the videoCompression. Defaults to AVAssetExportPresetHighestQuality */
		config.video.compression = AVAssetExportPresetPassthrough

		/* Choose the recordingSizeLimit. If not setted, then limit is by time. */
		// config.video.recordingSizeLimit = 10000000

		/* Defines the name of the album when saving pictures in the user's photo library.
		 In general that would be your App name. Defaults to "DefaultYPImagePickerAlbumName" */
		// config.albumName = "ThisIsMyAlbum"

		/* Defines which screen is shown at launch. Video mode will only work if `showsVideo = true`.
		 Default value is `.photo` */
		config.startOnScreen = .library

		/* Defines which screens are shown at launch, and their order.
		 Default value is `[.library, .photo]` */
		config.screens = [.library, .photo, .video]

		/* Can forbid the items with very big height with this property */
		config.library.minWidthForItem = UIScreen.main.bounds.width * 0.8

		/* Defines the time limit for recording videos.
		 Default is 30 seconds. */
		// config.video.recordingTimeLimit = 5.0

		/* Defines the time limit for videos from the library.
		 Defaults to 60 seconds. */
		config.video.libraryTimeLimit = 500.0

		/* Adds a Crop step in the photo taking process, after filters. Defaults to .none */
		config.showsCrop = .rectangle(ratio: 16 / 9)

		/* Changes the crop mask color */
		// config.colors.cropOverlayColor = .green

		/* Defines the overlay view for the camera. Defaults to UIView(). */
		// let overlayView = UIView()
		// overlayView.backgroundColor = .red
		// overlayView.alpha = 0.3
		// config.overlayView = overlayView

		/* Customize wordings */
		config.wordings.libraryTitle = "Gallery"

		/* Defines if the status bar should be hidden when showing the picker. Default is true */
		config.hidesStatusBar = false

		/* Defines if the bottom bar should be hidden when showing the picker. Default is false */
		config.hidesBottomBar = false

		config.maxCameraZoomFactor = 2.0

		config.library.maxNumberOfItems = 5
		config.gallery.hidesRemoveButton = false

		/* Disable scroll to change between mode */
		// config.isScrollToChangeModesEnabled = false
		// config.library.minNumberOfItems = 2

		/* Skip selection gallery after multiple selections */
		// config.library.skipSelectionsGallery = true

		/* Here we use a per picker configuration. Configuration is always shared.
		 That means than when you create one picker with configuration, than you can create other picker with just
		 let picker = YPImagePicker() and the configuration will be the same as the first picker. */

		/* Only show library pictures from the last 3 days */
		// let threDaysTimeInterval: TimeInterval = 3 * 60 * 60 * 24
		// let fromDate = Date().addingTimeInterval(-threDaysTimeInterval)
		// let toDate = Date()
		// let options = PHFetchOptions()
		// options.predicate = NSPredicate(format: "creationDate > %@ && creationDate < %@", fromDate as CVarArg, toDate as CVarArg)
		//
		////Just a way to set order
		// let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
		// options.sortDescriptors = [sortDescriptor]
		//
		// config.library.options = options

		config.library.preselectedItems = selectedItems

		// Customise fonts
		// config.fonts.menuItemFont = UIFont.systemFont(ofSize: 22.0, weight: .semibold)
		// config.fonts.pickerTitleFont = UIFont.systemFont(ofSize: 22.0, weight: .black)
		// config.fonts.rightBarButtonFont = UIFont.systemFont(ofSize: 22.0, weight: .bold)
		// config.fonts.navigationBarTitleFont = UIFont.systemFont(ofSize: 22.0, weight: .heavy)
		// config.fonts.leftBarButtonFont = UIFont.systemFont(ofSize: 22.0, weight: .heavy)

		let picker = YPImagePicker(configuration: config)

		picker.imagePickerDelegate = self

		/* Change configuration directly */
		// YPImagePickerConfiguration.shared.wordings.libraryTitle = "Gallery2"

		/* Multiple media implementation */
		picker.didFinishPicking { [weak picker] items, cancelled in

			if cancelled {
				print("Picker was canceled")
				picker?.dismiss(animated: true, completion: nil)
				return
			}
			_ = items.map { print("🧀 \($0)") }

			self.selectedItems = items
			if let firstItem = items.first {
				switch firstItem {
				case .photo(let photo):
					self.selectedImageV.image = photo.image
					picker?.dismiss(animated: true, completion: nil)
				case .video(let video):
					self.selectedImageV.image = video.thumbnail

					let assetURL = video.url
					let playerVC = AVPlayerViewController()
					let player = AVPlayer(playerItem: AVPlayerItem(url: assetURL))
					playerVC.player = player

					picker?.dismiss(animated: true, completion: { [weak self] in
						self?.present(playerVC, animated: true, completion: nil)
						print("😀 \(String(describing: self?.resolutionForLocalVideo(url: assetURL)!))")
					})
				}
			}
		}

		/* Single Photo implementation. */
		// picker.didFinishPicking { [weak picker] items, _ in
		//     self.selectedItems = items
		//     self.selectedImageV.image = items.singlePhoto?.image
		//     picker.dismiss(animated: true, completion: nil)
		// }

		/* Single Video implementation. */
		// picker.didFinishPicking { [weak picker] items, cancelled in
		//    if cancelled { picker.dismiss(animated: true, completion: nil); return }
		//
		//    self.selectedItems = items
		//    self.selectedImageV.image = items.singleVideo?.thumbnail
		//
		//    let assetURL = items.singleVideo!.url
		//    let playerVC = AVPlayerViewController()
		//    let player = AVPlayer(playerItem: AVPlayerItem(url:assetURL))
		//    playerVC.player = player
		//
		//    picker.dismiss(animated: true, completion: { [weak self] in
		//        self?.present(playerVC, animated: true, completion: nil)
		//        print("😀 \(String(describing: self?.resolutionForLocalVideo(url: assetURL)!))")
		//    })
		// }

		present(picker, animated: true, completion: nil)
	}
}

// Support methods
public extension ExampleViewController {
	/* Gives a resolution for the video by URL */
	func resolutionForLocalVideo(url: URL) -> CGSize? {
		guard let track = AVURLAsset(url: url).tracks(withMediaType: AVMediaType.video).first else { return nil }
		let size = track.naturalSize.applying(track.preferredTransform)
		return CGSize(width: abs(size.width), height: abs(size.height))
	}
}

// YPImagePickerDelegate
extension ExampleViewController: YPImagePickerDelegate {
	public func imagePickerHasNoItemsInLibrary(_ picker: YPImagePicker) {
		// PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: self)
	}

	public func shouldAddToSelection(indexPath: IndexPath, numSelections: Int) -> Bool {
		return true // indexPath.row != 2
	}
}
