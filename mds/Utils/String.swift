import Foundation

// A function to construct multiline Strings
public func multiline(_ x: String...) -> String {
	return x.joined(separator: "\n")
}

var expressions = [String: NSRegularExpression]()

// Extend String with subscript and regex methods
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
	
	func splitByLength(_ length: Int) -> [String] {
		var result = [String]()
		var collectedCharacters = [Character]()
		collectedCharacters.reserveCapacity(length)
		var count = 0
		
		for character in self.characters {
			collectedCharacters.append(character)
			count += 1
			if (count == length) {
				// Reached the desired length
				count = 0
				result.append(String(collectedCharacters))
				collectedCharacters.removeAll(keepingCapacity: true)
			}
		}
		
		// Append the remainder
		if !collectedCharacters.isEmpty {
			result.append(String(collectedCharacters))
		}
		
		return result
	}
	
	func truncate(length: Int, trailing: String = "...") -> String {
		if self.characters.count > length {
			let stringLength = length - trailing.characters.count
			return self.substring(to: self.index(self.startIndex, offsetBy: stringLength)) + trailing
		} else {
			return self
		}
	}
}
