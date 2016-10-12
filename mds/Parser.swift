import Foundation

/**
	The possible Nodes to encounter while parsing a list of tokens

	- Header: A markdown header
	- Text: Normal markdown text
*/
public enum Node {
	case Header(Int, Int, String)
	case Text(Int, String)
}

// The PArser
class Parser {
	
	// The list of tokens to parse
	let tokens: [Token]
	
	// Where we are in the list of tokens
	var index = 0
	
	/**
		Initializes a new parser with a list of tokens to parse
	
		- Parameters:
			- tokens: The list of tokens to parse
	
		- Returns: A Parser object
	*/
	init(tokens: [Token]) {
		self.tokens = tokens
	}
	
	/**
		Returns the current token without advancing the index

		- Returns: The current token
	*/
	private func peekToken() -> Token? {
		if index >= tokens.count {
			return nil
		}
		return tokens[index]
	}
	
	/**
		Return the current token and advances the index

		- Returns: The current token
	*/
	private func popToken() -> Token {
		let token = tokens[index]
		index = index + 1
		return token
	}
	
	/**
		Parses a list of tokens
		
		- Returns: A list of parsed Nodes
	*/
	func parse() -> [Node] {
		var nodes = [Node]()
		
		// Iterate over all tokens
		while index < tokens.count {
			let token = popToken()
			switch token {
				
			// Keep all headers
			case .Header(let line, let depth, let text):
				nodes.append(.Header(line, depth, text));
				
			// For text tokens, check the next token
			case .Text(let line, let text):
				if let nextToken = peekToken() {
					switch nextToken {
					case .UnderlineHeader1:
						nodes.append(.Header(line, 1, text))
						_ = popToken()
					case .UnderlineHeader2:
						nodes.append(.Header(line, 2, text))
						_ = popToken()
					default:
						nodes.append(.Text(line, text))
					}
				} else {
					nodes.append(.Text(line, text))
				}
				
			default:
				()
			}
		}
		
		return nodes
	}
}
