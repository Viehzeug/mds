import Foundation

// The base class for a UI component
class Component {
	
	// The size of the component
	var size: Size
	
	// The location of the component
	var location: Location
	
	/**
		Creates a new Component
	
		- Returns: A new component
	*/
	init() {
		self.size = Size(width: 0, height: 0)
		self.location = Location(x: 0, y: 0)
	}
	
	/**
		Renders the component
	*/
	func render() {
		preconditionFailure("This method must be overridden")
	}
}
