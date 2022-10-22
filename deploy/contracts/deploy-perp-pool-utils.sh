#!/bin/bash

RPC_URL="https://arb1.arbitrum.io/rpc"

POOL_COMMITTER_ADDRESS=0xf52a27de6777a943f3ee19b7804f54c67bf64f72
PRICE_UTILS_ADDRESS=0xd64fddf52e5a8e5c4be23dbdcb62f6e8505c6dfd

forge create \
	--rpc-url $RPC_URL \
	--private-key=$PRIVATE_KEY \
	--constructor-args \
	  $POOL_COMMITTER_ADDRESS \
	  $PRICE_UTILS_ADDRESS \
	--verify \
	--etherscan-api-key=$ETHERSCAN_API_KEY \
	src/PerpPoolUtils.sol:PerpPoolUtils