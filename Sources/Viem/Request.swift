//
//  Request.swift
//  Viem
//
//  Created by Louis Stanko on 29.07.25.
//
import Foundation

struct AnyEncodable: Encodable {
	private let _encode: (Encoder) throws -> Void

	init<T: Encodable>(_ value: T) {
		self._encode = value.encode
	}

	func encode(to encoder: Encoder) throws {
		try _encode(encoder)
	}
}

struct JsonRpcPayload: Encodable {
	let jsonrpc = "2.0"
	let method: String
	let params: [AnyEncodable]
	let id = UUID().uuidString
	init(method: String, params: [AnyEncodable]) throws {
		self.method = method
		self.params = params
	}
}


struct BigUIntResponse: Decodable {
	let id: String
	let result: String
}

struct BlockResponse: Decodable {
	let id: String
	let result: Block
}



public struct Block: Decodable {
	let number: String
	let hash: String
	let mixHash: String
	let parentHash: String
	let nonce: String
	let sha3Uncles: String
	let logsBloom: String
	let transactionsRoot: String
	let stateRoot: String
	let receiptsRoot: String
	let miner: String
	let difficulty: String
	let totalDifficulty: String?
	let extraData: String
	let size: String
	let gasLimit: String
	let gasUsed: String
	let timestamp: String?
	let uncles: [String]
	let transactions: Transactions
	let baseFeePerGas: String
	let withdrawalsRoot: String
	let withdrawals: [Withdrawal]
	let blobGasUsed: String
	let excessBlobGas: String
	let parentBeaconBlockRoot: String

	struct Withdrawal: Codable {
		let index: String
		let validatorIndex: String
		let address: String
		let amount: String
	}
	
	struct Transaction: Codable {
		let blockHash: String
		let blockNumber: String
		let from: WalletAddress
		let gas: String
		let gasPrice: String
		let maxFeePerGas: String?
		let maxPriorityFeePerGas: String?
		let hash: String
		let input: String
		let nonce: String
		let to: String?
		let transactionIndex: String
		let value: String
		let type: String
		let accessList: [String]?
		let chainId: String?
		let v: String
		let r: String
		let s: String
		let yParity: String?
	}
	
	enum Transactions: Decodable {
		case transactions([Transaction])
		case hashes([String])
		case none

		init(from decoder: Decoder) throws {
			let container = try decoder.singleValueContainer()

			// Try decode [Transaction]
			if let transactions = try? container.decode([Transaction].self) {
				self = .transactions(transactions)
				return
			}

			// Try decode [String]
			if let hashes = try? container.decode([String].self) {
				self = .hashes(hashes)
				return
			}

			// Try decode nil
			if container.decodeNil() {
				self = .none
				return
			}

			// If none of above, throw an error
			throw DecodingError.typeMismatch(
				Transactions.self,
				DecodingError.Context(codingPath: decoder.codingPath,
									  debugDescription: "Expected [Transaction], [String], or null")
			)
		}
	}
}

struct Request {
	@available(iOS 13.0.0, *)
	static func post(_ url: URL, _ functionName: String, params: [any Encodable]) async throws -> Data {
		let encodableParams = params.map { AnyEncodable($0) }
		var request = URLRequest(url: url)
		request.httpMethod = "POST"

		request.httpBody = try JSONEncoder().encode(JsonRpcPayload(method: functionName, params: encodableParams))
		request.setValue("\(request.httpBody?.count ?? 0)", forHTTPHeaderField: "Content-Length")
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		
		let str = String(decoding: request.httpBody!, as: UTF8.self)
		print("Sending:\n\(str)")
		
		let (data, _) = try await URLSession.shared.data(for: request)
		
		return data
	}
}
