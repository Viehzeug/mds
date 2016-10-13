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

// A struct to represent the size of elements
struct Size {
	// The width of the element
	var width: Int
	
	// The height of the element
	var height: Int
}

// A struct to represent the location of elements
struct Location {
	// The x location of the element
	var x: Int
	
	// The y location of the element
	var y: Int
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
	
	// The current mode
	var mode: Mode = .Structure

	// The status Bar
	let statusBar: StatusBarView
	
	// The view to display the document structure
	let structureView: StructureView
	
	// The view to display the document text
	let textView: TextView
	
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
		
		// Initialize UI components
		statusBar = StatusBarView()
		structureView = StructureView(document: document)
		textView = TextView(document: document)
	}
	
	/**
		Starts displaying the UI
	*/
	func start() {
		reset()
		update()
		getInput()
	}
	
	/**
		Resets the screen
	*/
	private func reset() {
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
	private func getInput() {
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
							goUp()
						
						case .Down:
							goDown()
						
						default:
							()
						}
					}
					
				// Enter key switches mode
				case .Enter:
					switch self.mode {
					case .Structure:
						textView.line = structureView.selectedHeader.line
						mode = .Text
						
					case .Text:
						mode = .Structure
					}
					
					update()
				
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
		switch mode {
		case .Text:
			textView.goUp()
			
		case .Structure:
			structureView.goUp()
		}
		
		update()
	}
	
	/**
		Navigates down in the displayed data
	*/
	func goDown() {
		switch mode {
		case .Text:
			textView.goDown()
			
		case .Structure:
			structureView.goDown()
		}
		
		update()
	}
	
	/**
		Updates the UI
	*/
	func update() {
		clear()
		layout()
		render()
		refresh()
	}
	
	/**
		Lays out all UI components
	*/
	private func layout() {
		// Get current size
		let screenSize = getScreenSize()
		
		// Set the status bar
		statusBar.mode = mode
		statusBar.location = Location(x: 0, y: screenSize.height - 1)
		statusBar.size = Size(width: screenSize.width, height: 1)
		
		switch mode {
		case .Structure:
			structureView.location = Location(x: 0, y: 0)
			structureView.size = Size(width: screenSize.width, height: screenSize.height - 2)
			
		case .Text:
			textView.location = Location(x: 0, y: 0)
			textView.size = Size(width: screenSize.width, height: screenSize.height - 2)
		}
	}
	
	/**
		Renders the UI
	*/
	private func render() {
		// Render components
		switch mode {
		case .Text:
			textView.render()
			
		case .Structure:
			structureView.render()
		}
		
		statusBar.render()
		
		// Render divider lines
		move(Int32(statusBar.location.y - 1), Int32(statusBar.location.x))
		hline(UInt32(UInt8(ascii:"-")), Int32(statusBar.size.width))
	}

	/**
		Gets the current screen size

		- Returns: A tuple representing the screen size (width, height)
	*/
	private func getScreenSize() -> Size {
		let maxx = getmaxx(stdscr)
		let maxy = getmaxy(stdscr)
		return Size(width: Int(maxx), height: Int(maxy))
	}
}
