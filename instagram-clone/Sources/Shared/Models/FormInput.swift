import Foundation

public enum FormInputStatus {
	/// input has not been touched.
	case pure
	/// input is valid
	case valid
	/// input is not valid
	case invalid
}

public protocol FormInput {
	associatedtype Value: Equatable
	var pure: Bool { get }
	var value: Value { get }
	var status: FormInputStatus { get }
	var error: Error? { get }
	init(value: Value, pure: Bool, error: Error?)
}

extension FormInput {
	public var invalid: Bool {
		status == .invalid
	}
	public var status: FormInputStatus {
		if pure {
			return .pure
		}
		return error == nil ? .valid : .invalid
	}
	public var validated: Bool {
		status == .valid
	}
	public func pure(_ value: Value) -> Self {
		Self(value: value, pure: true, error: nil)
	}
	public func valid(_ value: Value) -> Self {
		Self(value: value, pure: false, error: nil)
	}
	public func dirty(_ value: Value, error: Error) -> Self {
		Self(value: value, pure: false, error: error)
	}
}
