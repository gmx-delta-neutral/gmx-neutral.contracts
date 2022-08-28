// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {GlpPurchaser, GlpPurchase} from "../src/GlpPurchaser.sol";
import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";
import {IGlpManager} from "gmx/IGlpManager.sol";
import {IERC20} from "openzeppelin-contracts/contracts/interfaces/IERC20.sol";
import {IGlp} from "gmx/IGlp.sol";
import {IVault} from "gmx/IVault.sol";
import {MockUsdc} from "test/mocks/MockUsdc.sol";
import {IGlpPriceUtils} from "src/IGlpPriceUtils.sol";
import {IRewardRouter} from "gmx/IRewardRouter.sol";


contract GlpPurchaserTest is Test {
    GlpPurchaser public glpPurchaser;
    MockUsdc public usdcToken;
    uint8 usdcDecimals = 6; 
    address mockAddress = address(0);

    function setUp() public {
        usdcToken = new MockUsdc("USDC Token", "USDC", usdcDecimals);
        vm.mockCall(
            address(0),
            abi.encodeWithSelector(IGlpPriceUtils.glpPrice.selector),
            abi.encode(1*10**18)
        );

       vm.mockCall(
            address(0),
            abi.encodeWithSelector(IRewardRouter.mintAndStakeGlp.selector),
            abi.encode(1996*10**15)
        );

        glpPurchaser = new GlpPurchaser(address(usdcToken), mockAddress, mockAddress, mockAddress);
    }

    function testCanBuyGlp() public {
        uint256 usdcAmount = 2*10**18;
        usdcToken.mint(address(this), usdcAmount);
        usdcToken.approve(address(glpPurchaser), usdcAmount);

        uint256 minGlpAmount = 1994*10**15;
        vm.expectCall(
            address(mockAddress),
            abi.encodeWithSelector(IRewardRouter.mintAndStakeGlp.selector, address(usdcToken), usdcAmount, 0, minGlpAmount)
        );


        GlpPurchase memory purchase = glpPurchaser.buyGlp(usdcAmount);

        assertEq(purchase.usdcAmount, usdcAmount);
        assertEq(purchase.glpAmount, 1996*10**15);
    }
}

