#!/bin/bash

RPC_URL="https://arb1.arbitrum.io/rpc"

POOL_COMMITTER_ADDRESS=0xf52a27de6777a943f3ee19b7804f54c67bf64f72
POOL_TOKEN_ADDRESS=0x6e5f70E345b4aFd271491290e026dd3d34CBb9f2
PRICE_UTILS_ADDRESS=0x420bb98f7f5d6b9987335eaef867a6b46d845209

forge create \
	--rpc-url $RPC_URL \
	--private-key=$PRIVATE_KEY \
	--constructor-args \
	  $POOL_COMMITTER_ADDRESS \
	  $POOL_TOKEN_ADDRESS \
	  $PRICE_UTILS_ADDRESS \
	--verify \
	--etherscan-api-key=$ETHERSCAN_API_KEY \
	src/PerpPoolUtils.sol:PerpPoolUtils