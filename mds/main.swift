import Foundation

// Get CLI arguments
let arguments = CommandLine.arguments

if arguments.count < 2 {
	print("Usage: mds <filename>")
	exit(1)
}

let file = arguments[1]

do {
	// Load file
	let text = try String(contentsOf: URL(fileURLWithPath: file), encoding: String.Encoding.utf8)
	
	// Parse document
	let doc = Document(withText: text)
	
	// Display UI
	UI(withDocument: doc).start()
	
} catch {
	print("Could not load file: " + file);
	exit(1)
}


