import Foundation

/// Default Spacing in App UI.
public enum AppSpacing {
	/// The default unit of spacing
	public static let spaceUnit: CGFloat = 16
		
	/// xxxs spacing value (1pt)
	public static let xxxs: CGFloat = 0.0625 * spaceUnit
		
	/// xxs spacing value (2pt)
	public static let xxs: CGFloat = 0.125 * spaceUnit
		
	/// xs spacing value (4pt)
	public static let xs: CGFloat = 0.25 * spaceUnit
		
	/// sm spacing value (8pt)
	public static let sm: CGFloat = 0.5 * spaceUnit
		
	/// md spacing value (12pt)
	public static let md: CGFloat = 0.75 * spaceUnit
		
	/// lg spacing value (16pt)
	public static let lg: CGFloat = spaceUnit
		
	/// xlg spacing value (24pt)
	public static let xlg: CGFloat = 1.5 * spaceUnit
		
	/// xxlg spacing value (40pt)
	public static let xxlg: CGFloat = 2.5 * spaceUnit
		
	/// xxxlg spacing value (64pt)
	public static let xxxlg: CGFloat = 4 * spaceUnit
}
