import Foundation

// Extend Collection objects with safe subscript accessors
extension Collection {

	// Returns the element at the specified index iff it is within bounds, otherwise nil.
	subscript (safe index: Index) -> Iterator.Element? {
		return index >= startIndex && index < endIndex ? self[index] : nil
	}
}
