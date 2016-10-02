import Foundation

public func printArray(_ tokens:[Any]) {
	for token in tokens {
		print(token)
	}
}

let source:String = multiline(
	"# Header",
    "## Subheader",
    "This is example text",
    "## Another Subheader",
    "Some more text",
    "This should be a headline after parsing",
    "====",
    "This should be a subheader after parsing",
    "------"
)

print("== LEXER ==\n")

let lexer = Lexer(input: source)
let tokens = lexer.tokenize()
printArray(tokens)

print("\n== PARSER == \n")

let parser = Parser(tokens: tokens)
let nodes = parser.parse()
printArray(nodes)

print("\n== TABLE OF CONTENTS ==\n");

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

printTOC(nodes)
