import Foundation

// The Document
class Document {
	
	// The text of the document, one line per item
	let text: [String]
	
	// The structure of the document
	let headers: [Header]
	
	/**
		Initializes a new Document with a given text
	
		- Parameters:
			- withText: The text of the document
	
		- Returns: A Document object
	*/
	init(withText: String) {
		
		// Store the text
		self.text = withText.components(separatedBy: "\n")
		
		// Process the document and store the structure
		let lexer = Lexer(input: withText)
		let tokens = lexer.tokenize()
		let parser = Parser(tokens: tokens)
		self.headers = parser.parse()
	}
	
	/**
		Returns a header at a given index
	
		- Parameters:
			- atIndex: The index of the header, e.g. 0 for the first header
	
		- Returns: The header at the given index
	*/
	func getHeader(atIndex: Int) -> Header? {
		return self.headers[safe: atIndex]
	}
}
