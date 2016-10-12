import Foundation

// The Document
class Document {
	
	// The text of the document, one line per item
	let text: [String]
	
	// The structure of the document
	let structure: [Node]
	
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
		self.structure = parser.parse()
	}
	
	/**
		Returns a header at a given index
	
		- Parameters:
			- atIndex: The index of the header, e.g. 0 for the first header
	
		- Returns: The header at the given index
	*/
	func getHeader(atIndex: Int) -> Node? {
		var headerCount = 0
		for node in self.structure {
			switch node {
			case .Header(_, _, _):
				if headerCount == atIndex {
					return node
				} else {
					headerCount += 1
				}
				
			default:
				()
			}
		}
		
		return nil
	}
}
