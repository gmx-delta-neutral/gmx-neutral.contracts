// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {GlpExchange} from "../src/GlpExchange.sol";
import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";
import {IGlpManager} from "gmx/IGlpManager.sol";
import {IERC20} from "openzeppelin-contracts/contracts/interfaces/IERC20.sol";
import {IGlp} from "gmx/IGlp.sol";
import {IVault} from "gmx/IVault.sol";
import {MockUsdc} from "test/mocks/MockUsdc.sol";
import {IPriceUtils} from "src/IPriceUtils.sol";
import {IRewardRouter} from "gmx/IRewardRouter.sol";
import {Purchase} from "src/IExchange.sol";

contract GlpPurchaserTest is Test {
    GlpExchange public glpExchange;
    MockUsdc public usdcToken;
    uint8 usdcDecimals = 6; 
    address mockAddress = address(0);
    uint256 expectedGlpMintAmount = 1996*10**15;

    function setUp() public {
        vm.mockCall(
            mockAddress,
            abi.encodeWithSelector(IPriceUtils.glpPrice.selector),
            abi.encode(1*10**6)
        );

       vm.mockCall(
            mockAddress,
            abi.encodeWithSelector(ERC20.transferFrom.selector),
            abi.encode(true)
        );

       vm.mockCall(
            mockAddress,
            abi.encodeWithSelector(ERC20.approve.selector),
            abi.encode(true)
        );

       vm.mockCall(
            mockAddress,
            abi.encodeWithSelector(ERC20.transfer.selector),
            abi.encode(true)
        );

       vm.mockCall(
            mockAddress,
            abi.encodeWithSelector(IRewardRouter.mintAndStakeGlp.selector),
            abi.encode(expectedGlpMintAmount)
        );

        glpExchange = new GlpExchange(mockAddress, mockAddress, mockAddress, mockAddress, mockAddress, mockAddress);
    }

    function testCanBuyGlp() public {
        uint256 usdcAmount = 2*10**18;
        usdcToken.mint(address(this), usdcAmount);
        usdcToken.approve(address(glpExchange), usdcAmount);

        uint256 minGlpAmount = 1994*10**15;
        vm.expectCall(
            address(mockAddress),
            abi.encodeCall(IRewardRouter.mintAndStakeGlp, (address(usdcToken), usdcAmount, 0, minGlpAmount))
        );

        Purchase memory purchase = glpExchange.buy(usdcAmount);

        assertEq(purchase.usdcAmount, usdcAmount);
        assertEq(purchase.tokenAmount, expectedGlpMintAmount);
    }
}

