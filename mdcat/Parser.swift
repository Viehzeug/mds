import Foundation

public enum Node {
	case Header(Int, Int, String)
	case Text(Int, String)
}

open class Parser {
	
	let tokens: [Token]
	var index = 0
	
	init(tokens: [Token]) {
		self.tokens = tokens
	}
	
	func peekToken() -> Token {
		return tokens[index]
	}
	
	func popToken() -> Token {
		let token = tokens[index]
		index = index + 1
		return token
	}
	
	func parse() -> [Node] {
		var nodes = [Node]()
		
		while index < tokens.count {
			let token = popToken()
			switch token {
			case .Header(let line, let depth, let text):
				nodes.append(.Header(line, depth, text));
				
			case .Text(let line, let text):
				switch peekToken() {
				case .UnderlineHeader1:
					nodes.append(.Header(line, 1, text))
					_ = popToken()
				case .UnderlineHeader2:
					nodes.append(.Header(line, 2, text))
					_ = popToken()
				default:
					nodes.append(.Text(line, text))
				}
				
			default:
				()
			}
		}
		
		return nodes
	}
}
