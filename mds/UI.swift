import Foundation
import Darwin.ncurses

/**
	The possible terminal signals

	- INT: Interrupt
	- WINCH: Window size change
*/
enum Signal: Int32 {
	case INT   = 2
	case WINCH = 28
}

/**
	The supported keys

	- Quit: The "q" key, to quit the application
	- Esc: The escape key
	- Up: The up arrow key
	- Down: The down arrow key
	- Enter: The enter key
*/
enum Key: UInt32 {
	case Quit	= 113
	case Esc	= 27
	case Up		= 65
	case Down	= 66
	case Enter	= 10
}

/**
	The possible modes for the UI

	- Text: Display the text of the document
	- Structure: Display the structure of the document
*/
enum Mode {
	case Text
	case Structure
}

/**
	Traps a signal

	- Parameters:
		- signum: The signal to trap
		- action: The action to perform
*/
func trap(signum:Signal, action:@escaping @convention(c) (Int32) -> ()) {
	signal(signum.rawValue, action)
}

// The UI
class UI {
	
	// The document to display
	let document: Document
	
	// The currently selected line in the text
	var textLine = 0
	
	// The currently selected line in the structure
	var structureLine = 0
	
	// The current mode
	var mode: Mode = .Structure
	
	// The currently selected node
	var selectedNode: Node

	/**
		Initializes the UI
	
		- Parameters:
			- withDocument: The document to display
	
		- Returns: A new UI object
	*/
	init(withDocument: Document) {
		
		// React to SIGINT
		trap(signum:.INT) { signal in
			endwin()
			exit(0)
		}
		
		// Store the document
		self.document = withDocument
		
		// By default, select the first node
		self.selectedNode = self.document.structure[0]
	}
	
	/**
		Starts displaying the UI
	*/
	func start() {
		self.reset()
		self.update()
		self.getInput()
	}
	
	/**
		Resets the screen
	*/
	func reset() {
		endwin()
		refresh()
		initscr()
		clear()
		noecho()
		curs_set(0)
	}
	
	/**
		Reads keyboard input and reacts accordingly
	*/
	func getInput() {
		while true {
			
			// Get the key pressed
			let rawKey = UInt32(getch())
			// addstr(String(rawKey))
			
			// Try to process the key
			if let key: Key = Key(rawValue: rawKey) {
			
				switch key {
					
				// Quit on "q" key
				case .Quit:
					endwin()
					exit(0)
				
				// Esc is an escape char which can be followed by other keycodes
				case .Esc:
					// Throw away next char
					_ = getch()
					
					// Try to parse next key
					if let nextKey: Key = Key(rawValue: UInt32(getch())) {
						
						switch nextKey {
						case .Up:
							self.goUp()
						
						case .Down:
							self.goDown()
						
						default:
							()
						}
					}
					
				// Enter key switches mode
				case .Enter:
					switch self.mode {
					case .Structure:
						switch self.selectedNode {
						case .Header(let line, _, _):
							self.textLine = line
							
						default:
							self.textLine = 0
						}
						
						self.mode = .Text
						
					case .Text:
						self.mode = .Structure
					}
					
					self.update()
				
				default:
					()
				}
			}
		}
	}
	
	/**
		Navigates up in the displayed data
	*/
	func goUp() {
		switch self.mode {
		case .Text:
			self.textLine = max(self.textLine-1, 0)
			
		case .Structure:
			if let header = self.document.getHeader(atIndex: self.structureLine - 1) {
				self.selectedNode = header
				self.structureLine -= 1
			}
		}
		
		self.update()
	}
	
	/**
		Navigates down in the displayed data
	*/
	func goDown() {
		switch self.mode {
		case .Text:
			self.textLine = min(self.textLine+1, self.document.text.count-1)
			
		case .Structure:
			if let header = self.document.getHeader(atIndex: self.structureLine + 1) {
				self.selectedNode = header
				self.structureLine += 1
			}
		}
		
		self.update()
	}
	
	/**
		Updates the UI
	*/
	func update() {
		clear()
		
		switch self.mode {
		case .Text:
			self.renderText()
			
		case .Structure:
			self.renderStructure()
		}
		
		refresh()
	}
	
	/**
		Renders the UI in Text mode
	*/
	func renderText() {
		var y:Int32 = 0
		let lines = self.document.text
		for line in lines[self.textLine..<lines.count] {
			move(y, 0)
			addstr(line)
			y += 1
		}
	}
	
	/**
		Renders the UI in Strcture mode
	*/
	func renderStructure() {
		var y = 0;
		for node in self.document.structure {
			switch node {
			case .Header(let line, let depth, let text):
				let indent = String(repeating: "  ", count: depth-1)
				let lineCursor = (y == self.structureLine ? " -> " : "    ")
				let lineForPrint = String(line+1)
				move(y+1, 0)
				addstr(lineCursor + indent + text + " (" + lineForPrint + ")")
				y += 1
				
			default:
				()
			}
		}
	}
}
