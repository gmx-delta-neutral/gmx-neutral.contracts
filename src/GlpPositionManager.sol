// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IPositionManager} from "src/IPositionManager.sol";
import {IPurchaser, Purchase} from "src/IPurchaser.sol";
import {IGlpPriceUtils} from "src/IGlpPriceUtils.sol";

contract GlpPositionManager is IPositionManager {
  IPurchaser private glpPurchaser;
  IGlpPriceUtils private glpPriceUtils;
  uint256 private costBasis;
  uint256 private tokenAmount;

  uint256 private constant USDC_MULTIPLIER = 1*10**6;
  uint256 private constant GLP_MULTIPLIER = 1*10**18;
  

  constructor(address _glpPurchaserAddress, address _glpPriceUtilsAddress) {
    glpPurchaser = IPurchaser(_glpPurchaserAddress);
    glpPriceUtils = IGlpPriceUtils(_glpPriceUtilsAddress);
  }

  function PositionWorth() public view returns (uint256) {
    uint256 glpPrice = glpPriceUtils.glpPrice();
    return tokenAmount * glpPrice / GLP_MULTIPLIER;
  }

  function CostBasis() public view returns (uint256) {
    return costBasis;
  }

  function BuyPosition(uint256 usdcAmount) external returns (uint256) {
    Purchase memory purchase = glpPurchaser.Purchase(usdcAmount);
    costBasis += purchase.usdcAmount;
    tokenAmount += purchase.tokenAmount;  
    return purchase.tokenAmount;
  }

  function Pnl() external view returns (int256) {
    return int256(PositionWorth()) - int256(CostBasis());
  }
}
