// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

enum ViemErrors: Error {
	case malformedAddress(String)
	case invalidKeyFormat
	case publicKeyCreationFailed(String)
}

