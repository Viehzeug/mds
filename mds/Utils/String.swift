import Foundation

public func multiline(_ x: String...) -> String {
	return x.joined(separator: "\n")
}

var expressions = [String: NSRegularExpression]()

public extension String {
	subscript (i: Int) -> Character {
		return self[self.index(self.startIndex, offsetBy: i)]
	}
 
	subscript (i: Int) -> String {
		return String(self[i] as Character)
	}
 
	subscript (r: Range<Int>) -> String {
		let start = self.index(self.startIndex, offsetBy: r.lowerBound)
		let end = self.index(self.startIndex, offsetBy: r.upperBound)
		
		return self[start...end]
	}
	
	public func match(_ regex: String) -> String? {
		let expression: NSRegularExpression
		if let exists = expressions[regex] {
			expression = exists
		} else {
			expression = try! NSRegularExpression(pattern: "^\(regex)", options: [])
			expressions[regex] = expression
		}
		
		let range = expression.rangeOfFirstMatch(in: self, options: [], range: NSMakeRange(0, self.utf16.count))
		if range.location != NSNotFound {
			return (self as NSString).substring(with: range)
		}
		return nil
	}
}
