#!/bin/bash

RPC_URL="https://arb1.arbitrum.io/rpc"
PRICE_UTILS_ADDRESS=0x420bb98f7f5d6b9987335eaef867a6b46d845209
GLP_UTILS_ADDRESS=0xb2c4f65dce5b90ebc74fcca1dcc60a5e42abfd90 
POOL_COMMITTER_ADDRESS=0xf52a27de6777a943f3ee19b7804f54c67bf64f72
USDC_ADDRESS=0xff970a61a04b1ca14834a43f5de4533ebddb5cc8
REWARD_ROUTER_ADDRESS=0xA906F338CB21815cBc4Bc87ace9e68c87eF8d8F1
DELTA_NEUTRAL_REBALANCER_ADDRESS=0x14656b60da71f4d18f899681df0faf5dcac5d3d8

forge create \
	--rpc-url $RPC_URL \
	--private-key=$PRIVATE_KEY \
	--constructor-args \
		$PRICE_UTILS_ADDRESS \
		$GLP_UTILS_ADDRESS \
		$POOL_COMMITTER_ADDRESS \
		$USDC_ADDRESS \
		$REWARD_ROUTER_ADDRESS \
		$DELTA_NEUTRAL_REBALANCER_ADDRESS \
	--verify \
	--etherscan-api-key=$ETHERSCAN_API_KEY \
	src/GlpPositionManager.sol:GlpPositionManager