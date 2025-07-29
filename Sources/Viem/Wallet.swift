//
//  Wallet.swift
//  Viem
//
//  Created by Louis Stanko on 29.07.25.
//

public typealias WalletAddress = String

func isValidChecksumAddress(_ address: WalletAddress) -> Bool {
	guard address.count == 42 && address.starts(with: "0x") else { return false }
	
	let address = String(address.dropFirst(2))
	let lowercaseAddress = address.lowercased()
	
	guard let data = lowercaseAddress.data(using: .ascii) else { return false }
	let hexHash = keccak256(data).reduce("") {$0 + String(format: "%02x", $1)}
	
	for (i, char) in address.enumerated() {
		let hashChar = hexHash[hexHash.index(hexHash.startIndex, offsetBy: i)]
		let hashValue = Int(String(hashChar), radix: 16)!

		if char.isLetter {
			let shouldBeUpper = hashValue >= 8
			if shouldBeUpper != char.isUppercase {
				return false
			}
		}
	}
	return true
}

extension WalletAddress {
	@available(iOS 16.0, *)
	func isValidWalletAddress() -> Bool {
		let regex = try! Regex(#"^(0x)?[0-9a-f]{40}$"#)
		let result = try? regex.ignoresCase().wholeMatch(in: self)
		
		if result?.startIndex == 0 && result?.endIndex == self.count {
			return true
		}
		
		let addressBody = self.dropFirst(2)
		if addressBody == addressBody.lowercased() || addressBody == addressBody.uppercased() {
			return true
		}
		
		return isValidChecksumAddress(self)
	}
}
