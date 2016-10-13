import Foundation

/**
	The possible Tokens to encounter while lexing a file

	- Header: A markdown header
	- UnderlineHeader1: An underline, indicating that the previous line is a Level 1 Header
	- UnderlineHeader2: An underline, indicating that the previous line is a Level 2 Header
	- Text: Normal markdown text
*/
public enum Token {
	case Header(Int, Int, String)
	case UnderlineHeader1()
	case UnderlineHeader2()
	case Text(Int, String)
}

// A list of regular expressions and how to convert them into tokens
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

// The Lexer
class Lexer {
	
	// The text to process
	let input: String
	
	/**
		Initializes a new lexer with a string to process
	
		- Parameters:
			- input: The text to process
	
		- Returns: A Lexer object
	*/
	init(input: String) {
		self.input = input
	}
	
	/**
		Processes the input string and extracts relevant tokens
	
		- Returns: A list of tokens
	*/
	func tokenize() -> [Token] {
		var tokens = [Token]()
		let content = input
		
		// Go through the input line by line
		for (i, line) in content.components(separatedBy: "\n").enumerated() {
			var matched = false
			
			// Check all patterns
			for (pattern, generator) in tokenList {
				
				// Append the token if we can match and process it
				if let m = line.match(pattern) {
					if let t = generator(i, m) {
						tokens.append(t)
					}

					matched = true
					break
				}
			}
			
			// Treat the line as text if we can't process it
			if !matched {
				tokens.append(.Text(i, line))
			}
		}
		
		return tokens
	}
}
