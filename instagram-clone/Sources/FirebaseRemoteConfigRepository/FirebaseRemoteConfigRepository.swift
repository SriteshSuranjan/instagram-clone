import FirebaseRemoteConfig
import Foundation

public enum FirebaseRemoteConfigException: Error {
	case initializeException(Error)
	case checkFeatureAvailableFailure(Error)
	case fetchRemoteDataFailure(Error)
	case activateFailure(Error)
	case fetchAndActivateFailure(Error)
	case setConfigFailure(Error)
}

public actor FirebaseRemoteConfigRepository {
	public var config: RemoteConfig!
	private var isInitialized = false
	public init() {}

	public func initialize() async throws {
		guard !isInitialized else { return }
		try await initializeRemoteConfig()
		isInitialized = true
	}

	private func initializeRemoteConfig() async throws {
		do {
			self.config = .remoteConfig()
			try await config.ensureInitialized()
			let configSettings = RemoteConfigSettings()
			configSettings.fetchTimeout = 10
			configSettings.minimumFetchInterval = 0
			config.configSettings = configSettings
			let _ = try await fetchAndActive()
		} catch {
			throw FirebaseRemoteConfigException.initializeException(error)
		}
	}

	public func isFeatureAvailable(_ key: String) -> Bool {
		let configValue = config.configValue(forKey: key)
		return configValue.boolValue
	}
	
	public func fetchRemoteData(_ key: String) -> String {
		config.configValue(forKey: key).stringValue ?? ""
	}
	
	public func activate() async throws {
		do {
			try await config.activate()
		} catch {
			throw FirebaseRemoteConfigException.activateFailure(error)
		}
	}
	
	public func fetchAndActive() async throws -> Bool {
		do {
			let status = try await config.fetchAndActivate()
			return status == .successFetchedFromRemote
		} catch {
			throw FirebaseRemoteConfigException.fetchAndActivateFailure(error)
		}
	}
}
