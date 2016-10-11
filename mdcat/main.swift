import Foundation

public func printArray(_ tokens:[Any]) {
	for token in tokens {
		print(token)
	}
}

public func printTOC(_ nodes:[Node]) {
	for node in nodes {
		switch node {
		case .Header(let line, let depth, let text):
			let indent = String(repeating: "  ", count:depth-1)
			print(indent + text + " (" + String(line) + ")")
			
		default:
			()
		}
	}
}

// Get CLI arguments
let arguments = CommandLine.arguments

if arguments.count < 2 {
	print("I need a file!")
	exit(1)
}

let file = arguments[1]

do {
	// Load file
	let text = try String(contentsOf: URL(fileURLWithPath: file), encoding: String.Encoding.utf8)
	
	// Parse document
	let doc = Document(withText: text)
	
	UI(withDocument: doc).start()
	
} catch {
	print("Could not load file: " + file);
	exit(1)
}


