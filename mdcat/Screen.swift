import Foundation
import Darwin.ncurses

enum Signal: Int32 {
	case INT   = 2
	case WINCH = 28
}

enum Key: UInt32 {
	case QUIT	= 113
	case ESC	= 27
	case UP		= 65
	case DOWN	= 66
	case ENTER	= 10
}

enum Mode {
	case TEXT
	case STRUCTURE
}

func trap(signum:Signal, action:@escaping @convention(c) (Int32) -> ()) {
	signal(signum.rawValue, action)
}

class UI {
	
	let document: Document
	
	var textLine = 0
	var structureLine = 0
	var mode: Mode = .STRUCTURE
	
	var selectedNode: Node

	init(withDocument: Document) {
		trap(signum:.INT) { signal in
			endwin()
			exit(0)
		}
		
		self.document = withDocument
		self.selectedNode = self.document.toc[0]
		
		self.reset()
		self.update()
		self.getInput()
	}
	
	func reset() {
		endwin()
		refresh()
		initscr()
		clear()
		noecho()
		curs_set(0)
	}
	
	func getInput() {
		while true {
			let rawKey = UInt32(getch())
			//addstr(String(rawKey))
			if let key: Key = Key(rawValue: rawKey) {
			
				switch key {
				case .QUIT:
					endwin()
					exit(0)
				
				case .ESC:
					// Throw away next char
					_ = getch()
					
					if let nextKey: Key = Key(rawValue: UInt32(getch())) {
						
						switch nextKey {
						case .UP:
							self.goUp()
						
						case .DOWN:
							self.goDown()
						
						default:
							()
						}
					}
					
				case .ENTER:
					switch self.mode {
					case .STRUCTURE:
						switch self.selectedNode {
						case .Header(let line, _, _):
							self.textLine = line
							
						default:
							self.textLine = 0
						}
						
						self.mode = .TEXT
						
					case .TEXT:
						self.mode = .STRUCTURE
					}
					
					self.update()
				
				default:
					()
				}
			}
		}
	}
	
	func goUp() {
		switch self.mode {
		case .TEXT:
			self.textLine = min(self.textLine-1, 0)
			
		case .STRUCTURE:
			if let header = self.document.getHeader(atIndex: self.structureLine - 1) {
				self.selectedNode = header
				self.structureLine -= 1
			}
		}
		
		self.update()
	}
	
	func goDown() {
		switch self.mode {
		case .TEXT:
			self.textLine = max(self.textLine+1, self.document.text.count-1)
			
		case .STRUCTURE:
			if let header = self.document.getHeader(atIndex: self.structureLine + 1) {
				self.selectedNode = header
				self.structureLine += 1
			}
		}
		
		self.update()
	}
	
	func update() {
		clear()
		
		switch self.mode {
		case .TEXT:
			self.renderText()
			
		case .STRUCTURE:
			self.renderTOC()
		}
		
		refresh()
	}
	
	func renderText() {
		var y:Int32 = 0
		let lines = self.document.text
		for line in lines[self.textLine..<lines.count] {
			move(y, 0)
			addstr(line)
			y += 1
		}
	}
	
	func renderTOC() {
		var y = 0;
		for node in self.document.toc {
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
