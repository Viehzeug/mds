import Foundation

public enum Token {
	case Header(Int, Int, String)
	case UnderlineHeader1()
	case UnderlineHeader2()
	case Text(Int, String)
}

let tokenList: [(regex:String, (Int, String) -> Token?)] = [
	("^# .*",		{ .Header($0, 1, $1[2..<$1.characters.count-1]) }),
	("^## .*",		{ .Header($0, 2, $1[3..<$1.characters.count-1]) }),
	("^### .*",		{ .Header($0, 3, $1[4..<$1.characters.count-1]) }),
	("^#### .*",	{ .Header($0, 4, $1[5..<$1.characters.count-1]) }),
	("^##### .*",	{ .Header($0, 5, $1[6..<$1.characters.count-1]) }),
	("^###### .*",	{ .Header($0, 6, $1[7..<$1.characters.count-1]) }),
	("^=+$",		{ _,_ in .UnderlineHeader1() }),
	("^-+$",		{ _,_ in .UnderlineHeader2() })
]

class Lexer {
	let input: String
	
	init(input: String) {
		self.input = input
	}
	
	open func tokenize() -> [Token] {
		var tokens = [Token]()
		let content = input
		
		for (i, line) in content.components(separatedBy: "\n").enumerated() {
			var matched = false
			
			for (pattern, generator) in tokenList {
				if let m = line.match(pattern) {
					if let t = generator(i, m) {
						tokens.append(t)
					}

					matched = true
					break
				}
			}
			
			if !matched {
				tokens.append(.Text(i, line))
			}
		}
		return tokens
	}
}
