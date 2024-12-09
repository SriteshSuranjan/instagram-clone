import SwiftUI

public extension AngularGradient {
	static let defaultGradient = AngularGradient(
		gradient: Gradient(colors: Assets.Colors.primaryGradient),
		center: .center,
		startAngle: .degrees(0),
		endAngle: .degrees(360)
	)
}

#Preview {
	Circle()
		.fill(Color(.systemGray6))
		.padding(4)
		.overlay {
			Circle()
				.stroke(AngularGradient.defaultGradient, lineWidth: 3, antialiased: true)
		}
		.frame(width: 84, height: 84)
}
