import Foundation

// A view to display the status bar
class StatusBarView: Component {
	
	// The current mode
	var mode: Mode
	
	/**
		Creates a new StatusBarView
	
		- Returns: A new StatusBarView
	*/
	override init() {
		self.mode = .Structure
		super.init()
	}
	
	/**
		Renders the status bar
	*/
	override func render() {
		// Draw status bar content
		move(Int32(location.y), Int32(location.x))
		let modeName: String = "Mode: " + {
			switch mode {
			case .Structure:
				return "Structure"
				
			case .Text:
				return "Text"
			}
		}()
		addstr(modeName)
	}
}
