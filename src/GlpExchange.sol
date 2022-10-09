// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {IERC20} from "openzeppelin-contracts/contracts/interfaces/IERC20.sol";
import {IRewardRouter} from "gmx/IRewardRouter.sol";
import {IVault} from "gmx/IVault.sol";
import {IGlpManager} from "gmx/IGlpManager.sol";
import {IGlp} from "gmx/IGlp.sol";
import {IPriceUtils} from "src/IPriceUtils.sol";
import {IExchange, Purchase, TradeType} from "src/IExchange.sol";
import {DeltaNeutralVault} from "src/DeltaNeutralVault.sol";

contract GlpExchange is IExchange, Test {
    ERC20 private usdcToken;
    IRewardRouter private rewardRouter;
    IVault private vault;
    IGlpManager private glpManager;
    IGlp private glp;
    IPriceUtils private priceUtils;
    address private usdcAddress;
    address private glpAddress;
    address private glpManagerAddress;
    DeltaNeutralVault private deltaNeutralVault;

    uint256 private constant PERCENT_DIVISOR = 1000;
    uint256 private constant BASIS_POINTS_DIVISOR = 10000;
    uint256 private constant DEFAULT_SLIPPAGE = 30;
    uint256 private constant PRICE_PRECISION = 10 ** 30;
    uint256 private constant USDC_DIVISOR = 1*10**6;

    constructor(address _usdcAddress, address _rewardRouterAddress, address _vaultAddress, address _priceUtilsAddress, address _glpManagerAddress, address _deltaNeutralVaultAddress) {
        usdcAddress = _usdcAddress;
        usdcToken = ERC20(_usdcAddress);
        rewardRouter = IRewardRouter(_rewardRouterAddress);
        vault = IVault(_vaultAddress);
        priceUtils = IPriceUtils(_priceUtilsAddress);
        glpManagerAddress = _glpManagerAddress;
        deltaNeutralVault = DeltaNeutralVault(_deltaNeutralVaultAddress);
    }

    modifier checkAllowance(uint amount) {
        require(usdcToken.allowance(msg.sender, address(this)) >= amount, "Allowance Error");
        _;
    }

    function tradeType() external pure returns (TradeType) {
        return TradeType.Buy;
    }

    function buy(uint256 usdcAmount) external returns (Purchase memory) {
        uint256 price = priceUtils.glpPrice();
        uint256 glpToPurchase = usdcAmount * price / USDC_DIVISOR;
        
        usdcToken.transferFrom(address(deltaNeutralVault), address(this), usdcAmount);

        uint256 glpAmountAfterSlippage = glpToPurchase * (BASIS_POINTS_DIVISOR - DEFAULT_SLIPPAGE) / BASIS_POINTS_DIVISOR;
        usdcToken.approve(address(glpManagerAddress), usdcAmount);
        emit log("testing1");
        uint256 glpAmount = rewardRouter.mintAndStakeGlp(usdcAddress, usdcAmount, 0, glpAmountAfterSlippage);

        bool success = usdcToken.transfer(address(deltaNeutralVault), glpAmount);


        if (!success) {
            revert("Transfer of glp to Delta neutral vault was not successful");
        }

        return Purchase({
            usdcAmount: usdcAmount,
            tokenAmount: glpAmount
        });
    }

    function sell(uint256) external returns (Purchase memory) {
        
    }
}
