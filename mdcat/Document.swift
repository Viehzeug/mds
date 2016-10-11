import Foundation

class Document {
	
	let text: [String]
	let toc: [Node]
	
	init(withText: String) {
		self.text = withText.components(separatedBy: "\n")
		
		// Lexer
		let lexer = Lexer(input: withText)
		let tokens = lexer.tokenize()
		
		// Parser
		let parser = Parser(tokens: tokens)
		self.toc = parser.parse()
	}
	
	func getHeader(atIndex: Int) -> Node? {
		var headerCount = 0
		for node in self.toc {
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
