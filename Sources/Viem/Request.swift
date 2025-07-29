//
//  Request.swift
//  Viem
//
//  Created by Louis Stanko on 29.07.25.
//
import Foundation

struct JsonRpcPayload: Encodable {
	let jsonrpc = "2.0"
	let method: String
	let params: [String]
	let id = UUID().uuidString
	init(method: String, params: [String]) {
		self.method = method
		self.params = params
	}
}

struct BalanceResponse: Decodable {
	let id: String
	let result: String
}

struct ChainIdResponse: Decodable {
	let id: String
	let result: String
}

struct Request {
	@available(iOS 13.0.0, *)
	static func post(_ url: URL, _ functionName: String, params: [String]) async throws -> Data {
		var request = URLRequest(url: url)
		request.httpMethod = "POST"

		request.httpBody = try JSONEncoder().encode(JsonRpcPayload(method: functionName, params: params))
		request.setValue("\(request.httpBody?.count ?? 0)", forHTTPHeaderField: "Content-Length")
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		
		let str = String(decoding: request.httpBody!, as: UTF8.self)
		print("Sending:\n\(str)")
		
		let (data, _) = try await URLSession.shared.data(for: request)
		
		return data
	}
}
