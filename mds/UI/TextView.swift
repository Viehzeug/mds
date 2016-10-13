import Foundation

// A view for displaying the text of a document
class TextView: DocumentView {
	
	/**
		Renders the structure of the document
	*/
	override func render() {
		var y = 0
		let endIndex = min(line + size.height, document.text.count)
		for textLine in document.text[line ..< endIndex] {
			if textLine.characters.count == 0 {
				y += 1
			} else {
				for segment in textLine.splitByLength(size.width) {
					move(Int32(y), 0)
					addstr(segment)
					y += 1
				}
			}
		}
	}
	
	/**
		Navigates down in the displayed data
	*/
	override func goDown() {
		line = min(line + 1, document.text.count - 1)
	}
	
	/**
		Navigates up in the displayed data
	*/
	override func goUp() {
		line = max(line - 1, 0)
	}
	
}
