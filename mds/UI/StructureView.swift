import Foundation

// A view for displaying the structure of a document
class StructureView: DocumentView {
	
	private(set) var selectedHeader: Header
	
	override init(document: Document) {
		// TODO: This crashes if the markdown file does not have any headers
		selectedHeader = document.headers[0]
		super.init(document: document)
	}
	
	/**
		Renders the structure of the document
	*/
	override func render() {
		// Calculate the offset
		if line >= offset + size.height {
			offset = line - size.height + 1
		} else if line < offset {
			offset = line
		}
		
		// Go over the document headers
		var y = 0;
		let endIndex = min(offset + size.height, document.headers.count)
		for header in document.headers[offset ..< endIndex] {
			
			let indent = String(repeating: "  ", count: header.depth-1)
			let lineCursor = ((offset + y) == line ? "-> " : "   ")
			let lineForPrint = String(header.line+1)
			
			let displayString = lineCursor + indent + header.text + " (" + lineForPrint + ")"
			
			move(Int32(y), 0)
			addstr(displayString.truncate(length: size.width, trailing: "..."))
			y += 1
		}
	}
	
	/**
		Navigates down in the displayed data
	*/
	override func goDown() {
		if let header = document.getHeader(atIndex: line + 1) {
			selectedHeader = header
			line += 1
		}
	}
	
	/**
		Navigates up in the displayed data
	*/
	override func goUp() {
		if let header = document.getHeader(atIndex: line - 1) {
			selectedHeader = header
			line -= 1
		}
	}
	
}
