import Foundation

// A base class for a view that displays the document
class DocumentView: Component {
	
	// The document to display
	let document: Document
	
	// The current line in the document
	var line: Int
	
	// The current offset in the document
	var offset: Int
	
	/**
		Creates a new DocumentView
		
		- Parameters:
			- document: The document to display
		
		- Returns: A new DocumentView
	*/
	init(document: Document) {
		self.document = document
		self.line = 0
		self.offset = 0
		super.init()
	}
	
	/**
		Navigates down in the displayed data
	*/
	func goDown() {
		preconditionFailure("This method must be overridden")
	}
	
	/**
		Navigates up in the displayed data
	*/
	func goUp() {
		preconditionFailure("This method must be overridden")
	}
}
