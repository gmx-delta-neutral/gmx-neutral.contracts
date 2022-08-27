// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {Glp} from "../src/Glp.sol";
import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";
import {IGlpManager} from "gmx/IGlpManager.sol";
import {IERC20} from "openzeppelin-contracts/contracts/interfaces/IERC20.sol";
import {IGlp} from "gmx/IGlp.sol";
import {IVault} from "gmx/IVault.sol";
import {MockUsdc} from "test/mocks/MockUsdc.sol";
import {IGlpPriceUtils} from "src/IGlpPriceUtils.sol";
import {IRewardRouter} from "gmx/IRewardRouter.sol";


contract GlpTest is Test {
    Glp public glp;
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
            abi.encode(0)
        );

        glp = new Glp(address(usdcToken), mockAddress, mockAddress, mockAddress);
    }

    function testCanBuyGlp() public {
        uint256 usdcAmount = 2*10**18;
        usdcToken.mint(address(this), usdcAmount);
        usdcToken.approve(address(glp), usdcAmount);

        uint256 minGlpAmount = 1994*10**15;
        vm.expectCall(
            address(mockAddress),
            abi.encodeWithSelector(IRewardRouter.mintAndStakeGlp.selector, address(usdcToken), usdcAmount, 0, minGlpAmount)
        );

        glp.buyGlp(usdcAmount);

        assertEq(usdcToken.balanceOf(address(glp)), usdcAmount);
        assertEq(usdcToken.balanceOf(address(this)), 0);

    }
}

