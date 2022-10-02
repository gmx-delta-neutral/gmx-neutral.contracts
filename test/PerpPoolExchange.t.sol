// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {PerpPoolExchange} from "src/PerpPoolExchange.sol";
import {IPoolCommitter} from "perp-pool/IPoolCommitter.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";

contract PerpPoolPurchaserTest is Test {
  PerpPoolExchange private perpPoolExchange;
  address private mockAddress = address(0);

  function setUp() public {
    perpPoolExchange = new PerpPoolExchange(mockAddress, mockAddress, mockAddress);

    vm.mockCall(
        address(0),
        abi.encodeWithSelector(IPoolCommitter.commit.selector),
        abi.encode()
    );

    vm.mockCall(
        address(0),
        abi.encodeWithSelector(ERC20.approve.selector),
        abi.encode(true)
    );

    vm.mockCall(
        address(0),
        abi.encodeWithSelector(ERC20.transferFrom.selector),
        abi.encode(true)
    );

  }

  function testCanBuy() public {
      uint256 usdcAmount = 5000;
      vm.expectCall(
          address(mockAddress),
          abi.encodeWithSelector(IPoolCommitter.commit.selector, bytes32(abi.encodePacked(usdcAmount)))
      );


      perpPoolExchange.buy(usdcAmount);
  }
}