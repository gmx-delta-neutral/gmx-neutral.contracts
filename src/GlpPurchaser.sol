// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "solmate/tokens/ERC20.sol";
import {IERC20} from "openzeppelin-contracts/contracts/interfaces/IERC20.sol";
import {IRewardRouter} from "gmx/IRewardRouter.sol";
import {IVault} from "gmx/IVault.sol";
import {IGlpManager} from "gmx/IGlpManager.sol";
import {IGlp} from "gmx/IGlp.sol";
import {IGlpPriceUtils} from "src/IGlpPriceUtils.sol";
import {IPurchaser, Purchase} from "src/IPurchaser.sol";

contract GlpPurchaser is IPurchaser {
    ERC20 private usdcToken;
    IRewardRouter private rewardRouter;
    IVault private vault;
    IGlpManager private glpManager;
    IGlp private glp;
    IGlpPriceUtils private glpPriceUtils;
    address private usdcAddress;
    address private glpAddress;
    address private glpManagerAddress;

    uint256 private constant PERCENT_DIVISOR = 1000;
    uint256 private constant BASIS_POINTS_DIVISOR = 10000;
    uint256 private constant DEFAULT_SLIPPAGE = 30;
    uint256 private constant PRICE_PRECISION = 10 ** 30;
    uint256 private constant USDC_DIVISOR = 1*10**6;

    constructor(address _usdcAddress, address _rewardRouterAddress, address _vaultAddress, address _glpPriceUtilsAddress, address _glpManagerAddress) {
        usdcAddress = _usdcAddress;
        usdcToken = ERC20(_usdcAddress);
        rewardRouter = IRewardRouter(_rewardRouterAddress);
        vault = IVault(_vaultAddress);
        glpPriceUtils = IGlpPriceUtils(_glpPriceUtilsAddress);
        glpManagerAddress = _glpManagerAddress;
    }

    modifier checkAllowance(uint amount) {
        require(usdcToken.allowance(msg.sender, address(this)) >= amount, "Allowance Error");
        _;
    }

    function Purchase(uint256 usdcAmount) external returns (Purchase memory) {
        uint256 price = glpPriceUtils.glpPrice();
        uint256 glpToPurchase = usdcAmount * price / USDC_DIVISOR;
        
        usdcToken.transferFrom(msg.sender, address(this), usdcAmount);

        uint256 glpAmountAfterSlippage = glpToPurchase * (BASIS_POINTS_DIVISOR - DEFAULT_SLIPPAGE) / BASIS_POINTS_DIVISOR;
        usdcToken.approve(address(glpManagerAddress), usdcAmount);
        uint256 glpAmount = rewardRouter.mintAndStakeGlp(usdcAddress, usdcAmount, 0, glpAmountAfterSlippage);

        return Purchase({
            usdcAmount: usdcAmount,
            tokenAmount: glpAmount
        });
    }
}
