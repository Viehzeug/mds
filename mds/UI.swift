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
	
	// The current offset of the structure list
	var structureOffset = 0
	
	// The current mode
	var mode: Mode = .Structure
	
	// The currently selected node
	var selectedHeader: Header

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
		// TODO: This crashes if the markdown file does not have any headers
		self.selectedHeader = self.document.headers[0]
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
						self.textLine = self.selectedHeader.line
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
				self.selectedHeader = header
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
				self.selectedHeader = header
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
		
		self.renderStatusBar()
		
		refresh()
	}
	
	/**
		Renders the UI in Text mode
	*/
	func renderText() {
		// Get screen size
		let screenSize = self.getScreenSize()
		
		// Render the document
		var y = 0
		let lines = self.document.text
		let endIndex = min(self.textLine + screenSize.1 - 2, lines.count)
		for line in lines[self.textLine ..< endIndex] {
			move(Int32(y), 0)
			addstr(line)
			y += 1
		}
	}
	
	/**
		Renders the UI in Structure mode
	*/
	func renderStructure() {
		// Get screen size
		let screenSize = self.getScreenSize()
		
		// Calculate the offset
		if self.structureLine >= self.structureOffset + screenSize.1 - 2 {
			self.structureOffset = self.structureLine - screenSize.1 + 3
		} else if self.structureLine < self.structureOffset {
			self.structureOffset = self.structureLine
		}
		
		// Go over the document headers
		var y = 0;
		let endIndex = min(self.structureOffset + screenSize.1 - 2, self.document.headers.count)
		for header in self.document.headers[self.structureOffset ..< endIndex] {
			
			let indent = String(repeating: "  ", count: header.depth-1)
			let lineCursor = ((self.structureOffset + y) == self.structureLine ? " -> " : "    ")
			let lineForPrint = String(header.line+1)
			move(Int32(y), 0)
			addstr(lineCursor + indent + header.text + " (" + lineForPrint + ")")
			y += 1
		}
	}
	
	/**
		Renders the status bar
	*/
	func renderStatusBar() {
		// Get screen size
		let screenSize = self.getScreenSize()
		
		// Draw divider line
		move(Int32(screenSize.1 - 2), 0)
		hline(UInt32(UInt8(ascii:"-")), Int32(screenSize.0))
		
		// Draw status bar content
		move(Int32(screenSize.1 - 1), 0)
		let modeName: String = "Mode: " + {
			switch self.mode {
			case .Structure:
				return "Structure"
				
			case .Text:
				return "Text"
			}
		}()
		addstr(modeName)
	}
	
	/**
		Gets the current screen size

		- Returns: A tuple representing the screen size (width, height)
	*/
	private func getScreenSize() -> (Int, Int) {
		let maxx = getmaxx(stdscr)
		let maxy = getmaxy(stdscr)
		return (Int(maxx), Int(maxy))
	}
}
