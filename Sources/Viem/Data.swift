//
//  Data.swift
//  Viem
//
//  Created by Louis Stanko on 29.07.25.
//
import Foundation

extension Data {
	init?(hex: String) {
		let hex = hex.dropFirst(hex.hasPrefix("0x") ? 2 : 0)
		guard hex.count % 2 == 0 else { return nil }

		var newData = Data(capacity: hex.count / 2)
		var index = hex.startIndex
		for _ in 0..<hex.count/2 {
			let nextIndex = hex.index(index, offsetBy: 2)
			guard let byte = UInt8(hex[index..<nextIndex], radix: 16) else { return nil }
			newData.append(byte)
			index = nextIndex
		}
		self = newData
	}
}
