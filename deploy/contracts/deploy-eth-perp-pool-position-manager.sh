#!/bin/bash

RPC_URL="https://arb1.arbitrum.io/rpc"
POOL_TOKEN_ADDRESS=0x6e5f70E345b4aFd271491290e026dd3d34CBb9f2
PRICE_UTILS_ADDRESS=0xd64fddf52e5a8e5c4be23dbdcb62f6e8505c6dfd
LEVERAGED_POOL_ADDRESS=0x8f4af5a3b58ea60e66690f30335ed8586e46aceb
TRACKING_TOKEN_ADDRESS=0x82af49447d8a07e3bd95bd0d56f35241523fbab1
POOL_COMMITTER_ADDRESS=0xf52a27de6777a943f3ee19b7804f54c67bf64f72
USDC_ADDRESS=0xff970a61a04b1ca14834a43f5de4533ebddb5cc8
PERP_POOL_UTILS_ADDRESS=0x90b5b7dc6b54d13ae34b859a6cdb61e1b1bebd28
DELTA_NEUTRAL_REBALANCER_ADDRESS=0x14656b60da71f4d18f899681df0faf5dcac5d3d8

forge create \
	--rpc-url $RPC_URL \
	--private-key=$PRIVATE_KEY \
	--constructor-args \
		$POOL_TOKEN_ADDRESS \
		$PRICE_UTILS_ADDRESS \
		$LEVERAGED_POOL_ADDRESS \
		$TRACKING_TOKEN_ADDRESS \
		$POOL_COMMITTER_ADDRESS \
		$USDC_ADDRESS \
		$PERP_POOL_UTILS_ADDRESS \
		$DELTA_NEUTRAL_REBALANCER_ADDRESS \
	--verify \
	--etherscan-api-key=$ETHERSCAN_API_KEY \
	src/PerpPoolPositionManager.sol:PerpPoolPositionManager



