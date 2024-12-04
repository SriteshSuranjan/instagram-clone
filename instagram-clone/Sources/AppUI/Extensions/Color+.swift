import Foundation
import SwiftUI
import UIKit

public func addColor(_ color1: UIColor, with color2: UIColor) -> UIColor {
	var (r1, g1, b1, a1) = (CGFloat(0), CGFloat(0), CGFloat(0), CGFloat(0))
	var (r2, g2, b2, a2) = (CGFloat(0), CGFloat(0), CGFloat(0), CGFloat(0))

	color1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
	color2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)

	// add the components, but don't let them go above 1.0
	return UIColor(red: min(r1 + r2, 1), green: min(g1 + g2, 1), blue: min(b1 + b2, 1), alpha: (a1 + a2) / 2)
}

public func multiplyColor(_ color: UIColor, by multiplier: CGFloat) -> UIColor {
	var (r, g, b, a) = (CGFloat(0), CGFloat(0), CGFloat(0), CGFloat(0))
	color.getRed(&r, green: &g, blue: &b, alpha: &a)
	return UIColor(red: r * multiplier, green: g * multiplier, blue: b * multiplier, alpha: a)
}

public extension UIColor {
	static func +(color1: UIColor, color2: UIColor) -> UIColor {
		addColor(color1, with: color2)
	}

	static func *(color: UIColor, multiplier: Double) -> UIColor {
		multiplyColor(color, by: CGFloat(multiplier))
	}
}

extension Color {
	/// 将两个颜色按照 Alpha 通道进行混合
	/// - Parameters:
	///   - foreground: 前景色（上层颜色）
	///   - background: 背景色（下层颜色）
	/// - Returns: 混合后的新颜色
	static func alphaBlend(foreground: Color, background: Color) -> Color {
		// 将 Color 转换为 RGBA 分量
		let fore = foreground.rgbaComponents()
		let back = background.rgbaComponents()
				
		let alpha = fore.alpha
				
		// 如果前景色完全透明，直接返回背景色
		if alpha == 0 {
			return background
		}
				
		let invAlpha = 1 - alpha
		var backAlpha = back.alpha
				
		// 背景色不透明的情况
		if backAlpha == 1 {
			return Color(
				red: alpha * fore.red + invAlpha * back.red,
				green: alpha * fore.green + invAlpha * back.green,
				blue: alpha * fore.blue + invAlpha * back.blue,
				opacity: 1
			)
		} else {
			// 通用情况：两个颜色都有透明度
			backAlpha = backAlpha * invAlpha
			let outAlpha = alpha + backAlpha
						
			// 确保最终透明度不为0
			guard outAlpha != 0 else { return .clear }
						
			return Color(
				red: (fore.red * alpha + back.red * backAlpha) / outAlpha,
				green: (fore.green * alpha + back.green * backAlpha) / outAlpha,
				blue: (fore.blue * alpha + back.blue * backAlpha) / outAlpha,
				opacity: outAlpha
			)
		}
	}
		
	private func rgbaComponents() -> (red: Double, green: Double, blue: Double, alpha: Double) {
		#if canImport(UIKit)
		typealias NativeColor = UIColor
		#elseif canImport(AppKit)
		typealias NativeColor = NSColor
		#endif
					
		var r: CGFloat = 0
		var g: CGFloat = 0
		var b: CGFloat = 0
		var a: CGFloat = 0
					
		let nativeColor = NativeColor(self)
					
		nativeColor.getRed(&r, green: &g, blue: &b, alpha: &a)
					
		return (
			red: Double(r),
			green: Double(g),
			blue: Double(b),
			alpha: Double(a)
		)
	}
}
