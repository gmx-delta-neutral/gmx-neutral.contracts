#!/bin/bash

RPC_URL="https://arb1.arbitrum.io/rpc"
PRICE_UTILS_ADDRESS=0x420bb98f7f5d6b9987335eaef867a6b46d845209
GLP_UTILS_ADDRESS=0xb2c4f65dce5b90ebc74fcca1dcc60a5e42abfd90 
GLP_TOKENS=[0xff970a61a04b1ca14834a43f5de4533ebddb5cc8,0x2f2a2543b76a4166549f7aab2e75bef0aefc5b0f,0x82af49447d8a07e3bd95bd0d56f35241523fbab1,0xda10009cbd5d07dd0cecc66161fc93d7c9000da1]

forge create \
	--rpc-url $RPC_URL \
	--private-key=$PRIVATE_KEY \
	--constructor-args \
		$PRICE_UTILS_ADDRESS \
		$GLP_UTILS_ADDRESS \
		$POOL_COMMITTER_ADDRESS \
		$USDC_ADDRESS \
		$DELTA_NEUTRAL_REBALANCER
	--verify \
	--etherscan-api-key=$ETHERSCAN_API_KEY \
	src/GlpPositionManager.sol:GlpPositionManager