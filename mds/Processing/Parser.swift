import Foundation

// A markdown header
public struct Header {
	
	// The line at which the header appears in the document
	let line: Int
	
	// The depth (level) of the header
	let depth: Int
	
	// The text of the header
	let text: String
}

// The Parser
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
		
		- Returns: A list of Headers
	*/
	func parse() -> [Header] {
		var nodes = [Header]()
		
		// Iterate over all tokens
		while index < tokens.count {
			let token = popToken()
			switch token {
				
			// Keep all headers
			case .Header(let line, let depth, let text):
				nodes.append(Header(line: line, depth: depth, text: text));
				
			// For text tokens, check the next token
			case .Text(let line, let text):
				if let nextToken = peekToken() {
					switch nextToken {
					case .UnderlineHeader1:
						nodes.append(Header(line: line, depth: 1, text: text))
						_ = popToken()
					case .UnderlineHeader2:
						nodes.append(Header(line: line, depth: 2, text: text))
						_ = popToken()
					default:
						()
					}
				} else {
					()
				}
				
			default:
				()
			}
		}
		
		return nodes
	}
}
