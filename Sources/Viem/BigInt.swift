//
//  BigInt.swift
//  Viem
//
//  Created by Louis Stanko on 29.07.25.
//

import Foundation

public typealias BigUInt = String

extension BigUInt {
	
	/// Checks if the number is valid (only digits 0–9).
	func isValidBigUInt() -> Bool {
		return allSatisfy(\.isWholeNumber)
	}

	/// Adds the current bigint to the parameter bigint and returns the result as a new bigint.
	func add(x: BigUInt) -> BigUInt {
		let a = Array(self.reversed())
		let b = Array(x.reversed())
		var carry = 0
		var result: [Character] = []
		
		let maxLength = max(a.count, b.count)
		
		for i in 0..<maxLength {
			let digitA = i < a.count ? a[i].wholeNumberValue! : 0
			let digitB = i < b.count ? b[i].wholeNumberValue! : 0
			let sum = digitA + digitB + carry
			carry = sum / 10
			result.append(Character(String(sum % 10)))
		}
		
		if carry > 0 {
			result.append(Character(String(carry)))
		}
		
		return String(result.reversed())
	}

	/// Multiplies the current bigint with the parameter bigint and returns the result as a new bigint.
	func mul(x: BigUInt) -> BigUInt {
		let a = Array(self.reversed()).compactMap { $0.wholeNumberValue }
		let b = Array(x.reversed()).compactMap { $0.wholeNumberValue }
		var result = [Int](repeating: 0, count: a.count + b.count)

		for i in 0..<a.count {
			for j in 0..<b.count {
				result[i + j] += a[i] * b[j]
				if result[i + j] >= 10 {
					result[i + j + 1] += result[i + j] / 10
					result[i + j] %= 10
				}
			}
		}

		// Remove leading zeros
		while result.count > 1 && result.last == 0 {
			result.removeLast()
		}

		return result.reversed().map(String.init).joined()
	}

	/// Initializes a BigUInt from a hexadecimal string (e.g., "0x1A3F")
	init(hex: String) {
		let cleanedHex = hex.lowercased().hasPrefix("0x") ? String(hex.dropFirst(2)) : hex.lowercased()
		if cleanedHex.isEmpty {
			self = "0"
			return
		}

		var result: BigUInt = "0"
		for digit in cleanedHex {
			guard let value = digit.hexDigitValue else {
				self = "0"
				return
			}
			result = result.mul(x: "16").add(x: String(value))
		}

		self = result
	}
}
