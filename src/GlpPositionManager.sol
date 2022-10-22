// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {IPositionManager} from "src/IPositionManager.sol";
import {IPriceUtils} from "src/IPriceUtils.sol";
import {TokenExposure} from "src/TokenExposure.sol";
import {IVaultReader} from "gmx/IVaultReader.sol";
import {IGlpUtils} from "src/IGlpUtils.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import {IPoolCommitter} from "perp-pool/IPoolCommitter.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {TokenAllocation} from "src/TokenAllocation.sol";
import {GlpTokenAllocation} from "src/GlpTokenAllocation.sol";
import {DeltaNeutralRebalancer} from "src/DeltaNeutralRebalancer.sol";
import {IRewardRouter} from "gmx/IRewardRouter.sol";

contract GlpPositionManager is IPositionManager, Ownable, Test {
  uint256 private constant USDC_MULTIPLIER = 1*10**6;
  uint256 private constant GLP_MULTIPLIER = 1*10**18;
  uint256 private constant PERCENT_DIVISOR = 1000;
  uint256 private constant BASIS_POINTS_DIVISOR = 10000;
  uint256 private constant DEFAULT_SLIPPAGE = 30;
  uint256 private constant PRICE_PRECISION = 10 ** 30;

  uint256 private _costBasis;
  uint256 private tokenAmount;

  IPriceUtils private priceUtils;
  IGlpUtils private glpUtils;
  IPoolCommitter private poolCommitter;
  DeltaNeutralRebalancer private deltaNeutralRebalancer;
  ERC20 private usdcToken;
  IRewardRouter private rewardRouter;
  address[] private glpTokens;

  modifier onlyRebalancer {
    require(msg.sender == address(deltaNeutralRebalancer));
    _;
  }

  constructor(address _priceUtilsAddress, address _glpUtilsAddress, address _poolCommitterAddress, address _usdcAddress, address _rewardRouterAddress, address _deltaNeutralRebalancerAddress) {
    priceUtils = IPriceUtils(_priceUtilsAddress);
    glpUtils = IGlpUtils(_glpUtilsAddress);
    poolCommitter = IPoolCommitter(_poolCommitterAddress);
    usdcToken = ERC20(_usdcAddress);
    deltaNeutralRebalancer = DeltaNeutralRebalancer(_deltaNeutralRebalancerAddress);
    rewardRouter = IRewardRouter(_rewardRouterAddress);
  }

  function positionWorth() override public view returns (uint256) {
    uint256 glpPrice = priceUtils.glpPrice();
    return (tokenAmount * glpPrice / GLP_MULTIPLIER);
  }

  function costBasis() override public view returns (uint256) {
    return _costBasis;
  }

  function buy(uint256 usdcAmount) override external returns (uint256) {
    uint256 currentPrice = priceUtils.glpPrice();
    uint256 glpToPurchase = usdcAmount * currentPrice / USDC_MULTIPLIER;
    usdcToken.transferFrom(address(deltaNeutralRebalancer), address(this), usdcAmount);

    uint256 glpAmountAfterSlippage = glpToPurchase * (BASIS_POINTS_DIVISOR - DEFAULT_SLIPPAGE) / BASIS_POINTS_DIVISOR;
    uint256 glpAmount = rewardRouter.mintAndStakeGlp(address(usdcToken), usdcAmount, 0, glpAmountAfterSlippage);

    _costBasis += usdcAmount;
    tokenAmount += glpAmount;  
    return glpAmount;
  }

  function sell(uint256 usdcAmount) override external returns (uint256) {
    uint256 currentPrice = priceUtils.glpPrice();
    uint256 glpToSell = usdcAmount * currentPrice / USDC_MULTIPLIER;
    uint256 usdcAmountAfterSlippage = usdcAmount * (BASIS_POINTS_DIVISOR - DEFAULT_SLIPPAGE) / BASIS_POINTS_DIVISOR;

    uint256 usdcRetrieved = rewardRouter.unstakeAndRedeemGlp(address(usdcToken), glpToSell, usdcAmountAfterSlippage, address(deltaNeutralRebalancer));
    _costBasis -= usdcRetrieved;
    tokenAmount -= glpToSell;
    return usdcRetrieved;
  }

  function pnl() override external view returns (int256) {
    return int256(positionWorth()) - int256(costBasis());
  }

  function exposures() override external view returns (TokenExposure[] memory) {
    return glpUtils.getGlpTokenExposure(positionWorth(), glpTokens);
  }

  function allocation() override external view returns (TokenAllocation[] memory) {
    GlpTokenAllocation[] memory glpAllocations = glpUtils.getGlpTokenAllocations(glpTokens);
    TokenAllocation[] memory tokenAllocations = new TokenAllocation[](glpAllocations.length);

    for (uint i = 0; i < glpAllocations.length; i++) {
      tokenAllocations[i] = TokenAllocation({
        tokenAddress: glpAllocations[i].tokenAddress,
        percentage: glpAllocations[i].allocation,
        leverage: 1
      });
    }

    return tokenAllocations;
  }

  function canRebalance() override external pure returns (bool) {
    return true;
  }

  function price() override external view returns (uint256) {
    return priceUtils.glpPrice();
  }

  function setGlpTokens(address[] memory _glpTokens) external onlyOwner() {
    glpTokens = _glpTokens;
  }
}
