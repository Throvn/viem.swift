//
//  WalletClient.swift
//  Viem
//
//  Created by Louis Stanko on 29.07.25.
//
import Foundation
import secp256k1

public class WalletClient {
	let chainData: ChainData
	init(chain: ChainData) {
		self.chainData = chain
	}
	
}

public func createWalletClient(chain: Chain) -> WalletClient {
	let chain = getChainData(chain: chain)
	return WalletClient(chain: chain)
}



public func privateKeyToAccount(_ privateKeyHex: String) throws -> WalletAddress {
	// 1. Decode hex string to 32-byte Data
	guard let privKeyData = Data(hex: privateKeyHex), privKeyData.count == 32 else {
		throw ViemErrors.invalidKeyFormat
	}

	// 2. Create secp256k1 context
	guard let ctx = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN)) else {
		throw ViemErrors.publicKeyCreationFailed("Could not create context")
	}

	// 3. Generate public key struct
	var pubkey = secp256k1_pubkey()

	// 4. Get raw bytes
	let result = privKeyData.withUnsafeBytes { (privKeyBytes: UnsafeRawBufferPointer) -> Int32 in
		guard let privKeyPointer = privKeyBytes.bindMemory(to: UInt8.self).baseAddress else {
			return 0
		}
		return secp256k1_ec_pubkey_create(ctx, &pubkey, privKeyPointer)
	}

	guard result == 1 else {
		secp256k1_context_destroy(ctx)
		throw ViemErrors.publicKeyCreationFailed("Could not get private key pointer")
	}

	print("Public key created successfully")

	// 5. Serialize public key (compressed)
	var serializedPubkey = [UInt8](repeating: 0, count: 65)
	var outputLength = serializedPubkey.count

	_ = secp256k1_ec_pubkey_serialize(
		ctx,
		&serializedPubkey,
		&outputLength,
		&pubkey,
		UInt32(SECP256K1_EC_UNCOMPRESSED)
	)

	let pubKeyHex = Data(serializedPubkey).map { String(format: "%02x", $0) }.joined()
	
	print("Compressed Public Key: \(pubKeyHex)")

	// 5. Drop the 0x04 prefix byte
	let pubkey64 = Data(serializedPubkey.dropFirst())

	// 6. Keccak256 hash the public key
	let keccakHash = keccak256(pubkey64)

	// 7. Take the last 20 bytes for the address
	let addressData = keccakHash.suffix(20)
	let address = "0x" + addressData.map { String(format: "%02x", $0) }.joined()

	// 8. Output Ethereum address
	print("Ethereum Address: \(address)")

	// Cleanup
	secp256k1_context_destroy(ctx)
	
	return address
}

