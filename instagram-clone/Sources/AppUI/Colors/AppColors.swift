import SwiftUI

/// Defines the color palette for the App UI Kit.
public enum AppColors {
	/// Black
	public static let black = Color.black
		
	/// The background color.
	public static let background = Color(red: 32/255, green: 30/255, blue: 30/255)
		
	/// White
	public static let white = Color.white
		
	/// Transparent
	public static let transparent = Color.clear
		
	/// The light blue color.
	public static let lightBlue = Color(red: 100/255, green: 181/255, blue: 246/255)
		
	/// The blue primary color and swatch.
	public static let blue = Color(hex: 0x3898EC)
		
	/// The deep blue color.
	public static let deepBlue = Color(hex: 0x337EFF)
		
	/// The border outline color.
	public static let borderOutline = Color.white.opacity(0.18) // 45/255 ≈ 0.18
		
	/// Light dark.
	public static let lightDark = Color(white: 120/255, opacity: 0.64) // 164/255 ≈ 0.64
		
	/// Dark.
	public static let dark = Color(red: 58/255, green: 58/255, blue: 58/255)
		
	/// Primary dark blue color.
	public static let primaryDarkBlue = Color(hex: 0x1C1E22)
		
	/// Grey.
	public static let grey = Color.gray
		
	/// The bright grey color.
	public static let brightGrey = Color(red: 224/255, green: 224/255, blue: 224/255)
		
	/// The dark grey color.
	public static let darkGrey = Color(red: 66/255, green: 66/255, blue: 66/255)
		
	/// The emphasize grey color.
	public static let emphasizeGrey = Color(red: 97/255, green: 97/255, blue: 97/255)
		
	/// The emphasize dark grey color.
	public static let emphasizeDarkGrey = Color(red: 40/255, green: 37/255, blue: 37/255)
		
	/// Red material color.
	public static let red = Color.red
		
	/// The primary Instagram gradient pallete.
	public static let primaryGradient: [Color] = [
		Color(hex: 0x833AB4), // Purple
		Color(hex: 0xF77737), // Orange
		Color(hex: 0xE1306C), // Red-pink
		Color(hex: 0xC13584), // Red-purple
		Color(hex: 0x833AB4) // Duplicate of the first color
	]
		
	/// The primary Telegram gradient chat background pallete.
	public static let primaryBackgroundGradient: [Color] = [
		Color(red: 119/255, green: 69/255, blue: 121/255),
		Color(red: 141/255, green: 124/255, blue: 189/255),
		Color(red: 50/255, green: 94/255, blue: 170/255),
		Color(red: 111/255, green: 156/255, blue: 189/255)
	]
		
	/// The primary Telegram gradient chat message bubble pallete.
	public static let primaryMessageBubbleGradient: [Color] = [
		Color(red: 226/255, green: 128/255, blue: 53/255),
		Color(red: 228/255, green: 96/255, blue: 182/255),
		Color(red: 107/255, green: 73/255, blue: 195/255),
		Color(red: 78/255, green: 173/255, blue: 195/255)
	]
}

// Helper extension for creating colors from hex values
extension Color {
	init(hex: UInt32) {
		let red = Double((hex >> 16) & 0xFF)/255.0
		let green = Double((hex >> 8) & 0xFF)/255.0
		let blue = Double(hex & 0xFF)/255.0
		self.init(red: red, green: green, blue: blue)
	}
}

public extension Color {
	public enum MaterialGray {
		public static let shade100 = Color(white: 0.96)
		public static let shade200 = Color(white: 0.93)
		public static let shade300 = Color(white: 0.88)
		public static let shade400 = Color(white: 0.74)
		public static let shade500 = Color(white: 0.62)
		public static let shade600 = Color(white: 0.54)
		public static let shade700 = Color(white: 0.46)
		public static let shade800 = Color(white: 0.38)
		public static let shade900 = Color(white: 0.30)
	}
}
