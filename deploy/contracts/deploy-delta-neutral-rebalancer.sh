#!/bin/bash

RPC_URL="https://arb1.arbitrum.io/rpc"
BTC_ADDRESS=0x2f2a2543b76a4166549f7aab2e75bef0aefc5b0f
ETH_ADDRESS=0x82af49447d8a07e3bd95bd0d56f35241523fbab1
USDC_ADDRESS=0xff970a61a04b1ca14834a43f5de4533ebddb5cc8

forge create \
	--rpc-url $RPC_URL \
	--private-key=$PRIVATE_KEY \
	--constructor-args \
		$BTC_ADDRESS \
		$ETH_ADDRESS \
		$USDC_ADDRESS \
	--verify \
	--etherscan-api-key=$ETHERSCAN_API_KEY \
	src/DeltaNeutralRebalancer.sol:DeltaNeutralRebalancer