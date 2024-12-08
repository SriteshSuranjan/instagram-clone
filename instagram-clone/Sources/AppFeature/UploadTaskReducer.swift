import Foundation
import UniformTypeIdentifiers
import ComposableArchitecture
import UploadTaskClient
import UserClient
import BlurHashClient
import Supabase
import AppLoadingIndeterminateClient
import SnackbarMessagesClient
import AppUI
import Shared

private let encoder: JSONEncoder = {
	let encoder = JSONEncoder()
	encoder.dateEncodingStrategy = .iso8601
	encoder.keyEncodingStrategy = .convertToSnakeCase
	return encoder
}()

@Reducer
public struct UploadTaskReducer<State> {
	
	@Dependency(\.uploadTaskClient) var uploadTaskClient
	@Dependency(\.userClient.storageUploaderClient) var uploaderClient
	@Dependency(\.blurHashClient) var blurHashClient
	@Dependency(\.userClient.databaseClient) var databaseClient
	@Dependency(\.uuid) var uuid
	@Dependency(\.appLoadingIndeterminateClient) var appLoadingIndeterminateClient
	@Dependency(\.snackbarMessagesClient) var snackbarMessagesClient
	
	public func reduce(into state: inout State, action: AppReducer.Action) -> Effect<AppReducer.Action> {
		switch action {
		case .appDelegate(.didFinishLaunching):
			return .none
		case .task:
			return .run { send in
				async let uploadTasks: Void = {
					for await task in await uploadTaskClient.tasks() {
						await send(.performUpLoadTask(task))
					}
				}()
				_ = await uploadTasks
			}
		case let .performUpLoadTask(task):
			switch task {
			case let .post(postUploadTask):
				let postId = postUploadTask.postId
				let selectedFiles = postUploadTask.files
				let isReel = selectedFiles.count == 1 && selectedFiles.allSatisfy { !$0.isImage }
				let caption = postUploadTask.caption
				return .run { send in
					await appLoadingIndeterminateClient.updateLoading(showLoading: true)
					if isReel {
						let mediaPath = "\(postId)/video_0"
						let selectedFile = selectedFiles.first!
						let firstFrame = selectedFile.selectedData
						let blurHash: String = firstFrame.count > 0 ? (await blurHashClient.encode(firstFrame) ?? "") : ""
						let videoData = try Data(contentsOf: selectedFile.selectedFile)
						let videoExtention = selectedFile.selectedFile.pathExtension
						let utm = UTType(filenameExtension: videoExtention)
						let mimeType = utm?.preferredMIMEType
						let fileUploadResponse = try await uploaderClient.uploadBinaryWithData(
							"posts",
							mediaPath,
							videoData,
							FileOptions(
								cacheControl: "9000000",
								contentType: mimeType
							)
						)
						let mediaUrl = try await uploaderClient.getPublicUrl("posts", fileUploadResponse.path)
						var firstFrameUrl: String?
						if firstFrame.count > 0 {
							let firstFramePath = "\(postId)/video_first_frame_0)"
							let firstFrameUploadResponse = try await uploaderClient.uploadBinaryWithData(
								"posts",
								firstFramePath,
								firstFrame,
								FileOptions(
									cacheControl: "9000000",
									contentType: mimeType
								)
							)
							firstFrameUrl = try await uploaderClient.getPublicUrl("posts", firstFrameUploadResponse.path)
						}
						let mediaJson = #"[{"media_id":"\#(uuid().uuidString.lowercased())","url":"\#(mediaUrl!)","type":"__video_media__","blur_hash":"\#(blurHash)","first_frame_url":"\#(firstFrameUrl ?? "")"}]"#
						let post = try await databaseClient.createPost(caption, mediaJson)
						debugPrint(post)
					} else {
						var media: [MediaItem] = []
						for (index, file) in selectedFiles.enumerated() {
							let isVideo = file.selectedFile.pathExtension == "mp4"
							var blurHash: String?
							var convertedBytes: Data?
							if isVideo {
								convertedBytes = try Data(contentsOf: file.selectedFile)
								if let convertedBytes {
									blurHash = await blurHashClient.encode(convertedBytes)
								}
							} else {
								blurHash = await blurHashClient.encode(file.selectedData)
							}
							let mediaExtension = file.selectedFile.pathExtension
							let videoPath = "\(postId)/video_\(index)"
							let imagePath = "\(postId)/image_\(index)"
							let mediaPath = isVideo ? videoPath : imagePath
							let bytes: Data
							if isVideo {
								bytes = try Data(contentsOf: file.selectedFile)
							} else {
								bytes = file.selectedData
							}
							let contentType = isVideo ? "video/\(mediaExtension)" : "image/\(mediaExtension)"
							let fileUploadResponse = try await uploaderClient.uploadBinaryWithData(
								"posts",
								mediaPath,
								bytes,
								FileOptions(
									cacheControl: "9000000",
									contentType: contentType
								)
							)
							let mediaUrl = try await uploaderClient.getPublicUrl("posts", fileUploadResponse.path)
							var firstFrameUrl: String?
							if let convertedBytes, convertedBytes.count > 0 {
								let firstFramePath = "\(postId)/video_first_frame_\(index)"
								let firstFrameUploadResponse = try await uploaderClient.uploadBinaryWithData(
									"posts",
									firstFramePath,
									convertedBytes,
									FileOptions(
										cacheControl: "9000000",
										contentType: "video/\(mediaExtension)"
									)
								)
								firstFrameUrl = try await uploaderClient.getPublicUrl("posts", firstFrameUploadResponse.path)
							}
							let mediaType = isVideo ? "__video_media__" : "__image_media__"
							if isVideo {
								let videoMedia = VideoMedia(id: uuid().uuidString.lowercased(), url: mediaUrl!, blurHash: blurHash, type: mediaType, firstFrameUrl: firstFrameUrl)
								media.append(.video(videoMedia))
							} else {
								let imageMedia = ImageMedia(id: uuid().uuidString.lowercased(), url: mediaUrl!, blurHash: blurHash, type: mediaType)
								media.append(.image(imageMedia))
							}
						}
						let mediaData = try encoder.encode(media)
						if let mediaJson = String(data: mediaData, encoding: .utf8) {
							let post = try await databaseClient.createPost(caption, mediaJson)
						}
					}
					await appLoadingIndeterminateClient.updateLoading(showLoading: false)
					await snackbarMessagesClient.show(message: .success(title: "Post has been published!", backgroundColor: Assets.Colors.snackbarSuccessBackground))
				} catch: { error, send in
					await appLoadingIndeterminateClient.updateLoading(showLoading: false)
					await snackbarMessagesClient.show(message: .error(title: "Failed to create post", backgroundColor: Assets.Colors.snackbarErrorBackground))
				}
			default: return .none
			}
		default: return .none
		}
	}
}
