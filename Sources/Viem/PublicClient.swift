//
//  PublicWallet.swift
//  Viem
//
//  Created by Louis Stanko on 29.07.25.
//
import Foundation

public struct PublicClient {
	let chainData: ChainData
	init(chain: ChainData) {
		self.chainData = chain
	}
	
	/// Queries the current balance and returns it in wei
	/// - Parameter address: The wallet address to check the balance of
	/// - Returns: The balance in wei, the smallest available currency
	@available(iOS 16.0, *)
	public func getBalance(_ address: WalletAddress) async throws -> BigUInt {
		guard address.isValidWalletAddress() else {
			throw ViemErrors.malformedAddress(address)
		}
		
		let data = try await Request.post(chainData.url, "eth_getBalance", params: [address, "latest"])
		
		do {
			let json = try JSONDecoder().decode(BigUIntResponse.self, from: data)
			let balance = BigUInt(hex: json.result)
			print("Balance is: \(balance) \(json.result)")
			
			return balance
		} catch {
			let str = String(decoding: data, as: UTF8.self)
			print("[getBalance] RPC Response:\n\(str)")
			throw error
		}
	}
	
	@available(iOS 16.0.0, *)
	public func getTransactionCount(_ address: WalletAddress) async throws -> UInt {
		guard address.isValidWalletAddress() else {
			throw ViemErrors.malformedAddress(address)
		}
		
		let data = try await Request.post(chainData.url, "eth_getTransactionCount", params: [address, "latest"])
		
		do {
			let json = try JSONDecoder().decode(BigUIntResponse.self, from: data)
			let txCount = BigUInt(hex: json.result)
			print("Transaction Count is: \(txCount) \(json.result)")
			
			return UInt(txCount)!
		} catch {
			let str = String(decoding: data, as: UTF8.self)
			print("[getTransactionCount] RPC Response:\n\(str)")
			throw error
		}

	}
	
	@available(iOS 13.0.0, *)
	public func getBlock(hydrated: Bool = false) async throws -> Block {
		let data = try await Request.post(chainData.url, "eth_getBlockByNumber", params: ["latest", hydrated])
		
		let str = String(decoding: data, as: UTF8.self)
		print("[getChainId] RPC Response:\n\(str)")
		
		do {
			let json = try JSONDecoder().decode(BlockResponse.self, from: data)
			let block = json.result
			print("Block is: \(block)")
			
			return block
		} catch {
			let str = String(decoding: data, as: UTF8.self)
			print("[getChainId] RPC Response:\n\(str)")
			throw error
		}
	}
	
	@available(iOS 13.0.0, *)
	public func getChainId() async throws -> UInt {
		let data = try await Request.post(chainData.url, "eth_chainId", params: [])
		
		do {
			let json = try JSONDecoder().decode(BigUIntResponse.self, from: data)
			let chainId = BigUInt(hex: json.result)
			print("Chain Id is: \(chainId) \(json.result)")
			
			return UInt(chainId)!
		} catch {
			let str = String(decoding: data, as: UTF8.self)
			print("[getChainId] RPC Response:\n\(str)")
			throw error
		}
	}
}


/// Creates a connection to an RPC client.
/// - Parameter chain: Chain which should be connected to
/// - Returns: public client which interacts with the chain node
public func createPublicClient(chain: Chain) -> PublicClient {
	let chain = getChainData(chain: chain)
	return PublicClient(chain: chain)
}

