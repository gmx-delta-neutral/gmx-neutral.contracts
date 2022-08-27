// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {GlpPriceUtils} from "src/GlpPriceUtils.sol";
import {MockUsdc} from "test/mocks/MockUsdc.sol";
import {IGlp} from "gmx/IGlp.sol";
import {IGlpManager} from "gmx/IGlpManager.sol";
import {IVault} from "gmx/IVault.sol";

contract GlpPriceUtilsTest is Test {
  GlpPriceUtils private glpPriceUtils;
  MockUsdc private usdcToken;
  address private mockAddress = address(0);
  uint8 private usdcDecimals = 6;

  function setUp() public {
        vm.mockCall(
            address(0),
            abi.encodeWithSelector(IGlpManager.getAumInUsdg.selector),
            abi.encode(500)
        );

       vm.mockCall(
            address(0),
            abi.encodeWithSelector(IGlp.totalSupply.selector),
            abi.encode(1000)
        );

       vm.mockCall(
            address(0),
            abi.encodeWithSelector(IVault.getFeeBasisPoints.selector),
            abi.encode(20)
      );

      vm.mockCall(
            address(0),
            abi.encodeWithSelector(IVault.mintBurnFeeBasisPoints.selector),
            abi.encode(25)
      );

      vm.mockCall(
            address(0),
            abi.encodeWithSelector(IVault.taxBasisPoints.selector),
            abi.encode(50)
      );
 
    usdcToken = new MockUsdc("USDC Token", "USDC", usdcDecimals);
    glpPriceUtils = new GlpPriceUtils(mockAddress, mockAddress, mockAddress, address(usdcToken));
  }

   function testGetGlpPrice() public {
      uint256 price = glpPriceUtils.glpPrice(); 

      assertEq(price, 500000);
  }
}