//
//  Chains.swift
//  Viem
//
//  Created by Louis Stanko on 29.07.25.
//
import Foundation

public enum Chain {
	case mainnet
	case sepolia
	case custom(ChainData)
}

public struct ChainData {
	let url: URL
	let id: Int?
	let symbol: String
	let explorerUrl: URL
}

func getChainData(chain: Chain) -> ChainData {
	switch chain {
	case .mainnet:
		return ChainData(url: URL(string: "https://eth.llamarpc.com")!, id: 1, symbol: "ETH", explorerUrl: URL(string:"https://etherscan.io")!)
	case .sepolia:
		return ChainData(url: URL(string: "https://ethereum-sepolia.rpc.subquery.network/public")!, id: 11155111, symbol: "SepoliaETH", explorerUrl: URL(string: "https://sepolia.etherscan.io")!)
	case .custom(let customChain):
		return customChain
	}
}
