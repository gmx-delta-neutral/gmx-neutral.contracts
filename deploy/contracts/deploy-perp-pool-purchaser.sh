forge create --rpc-url https://arb1.arbitrum.io/rpc --private-key=<private-key> --constructor-args \
0xf52a27de6777a943f3ee19b7804f54c67bf64f72 0xff970a61a04b1ca14834a43f5de4533ebddb5cc8 0x3aca4f1b1791d00ebbae01d65e9739c9c886f33c \
--verify --etherscan-api-key=<etherscan-api-key> src/PerpPoolPurchaser.sol:PerpPoolPurchase