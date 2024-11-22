import Foundation

public extension Int {
	var ms: TimeInterval { TimeInterval(self) / 1000 }
	var milliseconds: TimeInterval { self.ms }
		
	var seconds: TimeInterval { TimeInterval(self) }
	var second: TimeInterval { self.seconds }
		
	var minutes: TimeInterval { TimeInterval(self) * 60 }
	var minute: TimeInterval { self.minutes }
		
	var hours: TimeInterval { TimeInterval(self) * 3600 }
	var hour: TimeInterval { self.hours }
		
	var days: TimeInterval { TimeInterval(self) * 86400 }
	var day: TimeInterval { self.days }
}

public extension Double {
	var ms: TimeInterval { TimeInterval(self) / 1000 }
	var milliseconds: TimeInterval { self.ms }
		
	var seconds: TimeInterval { TimeInterval(self) }
	var second: TimeInterval { self.seconds }
		
	var minutes: TimeInterval { TimeInterval(self) * 60 }
	var minute: TimeInterval { self.minutes }
		
	var hours: TimeInterval { TimeInterval(self) * 3600 }
	var hour: TimeInterval { self.hours }
		
	var days: TimeInterval { TimeInterval(self) * 86400 }
	var day: TimeInterval { self.days }
}
