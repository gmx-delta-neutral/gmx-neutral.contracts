// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {GlpPositionManager} from "src/GlpPositionManager.sol";
import {IGlpPriceUtils} from "src/IGlpPriceUtils.sol";
import {IPurchaser, Purchase} from "src/IPurchaser.sol";

contract GlpPositionManagerTest is Test {
  address mockAddress = address(0);
  GlpPositionManager glpPositionManager;

  function setUp() public {
    glpPositionManager = new GlpPositionManager(mockAddress, mockAddress);

    vm.mockCall(
        address(0),
        abi.encodeWithSelector(IGlpPriceUtils.glpPrice.selector),
        abi.encode(1*10**6)
    );

    vm.mockCall(
        address(0),
        abi.encodeWithSelector(IPurchaser.Purchase.selector),
        abi.encode(Purchase({
          usdcAmount: 2*10**6,
          tokenAmount: 1996*10**15
        }))
    );
  }

  function testCanBuyPosition() public {
    uint256 usdcAmount = 2*10**6;
    uint256 expectedGlpAmount = 1996*10**15;
    uint256 expectedPositionWorth = 1996000;
    int256 expectedPnl = -4000;
    uint256 tokenAmount = glpPositionManager.BuyPosition(usdcAmount);
    assertEq(glpPositionManager.CostBasis(), usdcAmount);
    assertEq(tokenAmount, expectedGlpAmount);
    assertEq(glpPositionManager.PositionWorth(), expectedPositionWorth);
    assertEq(glpPositionManager.Pnl(), expectedPnl);
  }
} 
