// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IPositionManager} from "src/IPositionManager.sol";
import {IExchange, Purchase} from "src/IExchange.sol";
import {IPriceUtils} from "src/IPriceUtils.sol";
import {TokenExposure} from "src/TokenExposure.sol";
import {IVaultReader} from "gmx/IVaultReader.sol";
import {IGlpUtils} from "src/IGlpUtils.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import {IPoolCommitter} from "perp-pool/IPoolCommitter.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {TokenAllocation} from "src/TokenAllocation.sol";
import {GlpTokenAllocation} from "src/GlpTokenAllocation.sol";

contract GlpPositionManager is IPositionManager, Ownable {
  uint256 private constant USDC_MULTIPLIER = 1*10**6;
  uint256 private constant GLP_MULTIPLIER = 1*10**18;

  uint256 private _costBasis;
  uint256 private tokenAmount;

  IExchange private glpExchange;
  IPriceUtils private priceUtils;
  IGlpUtils private glpUtils;
  IPoolCommitter private poolCommitter;
  ERC20 private usdcToken;
  address[] private glpTokens;

  constructor(address _glpExchangeAddress, address _priceUtilsAddress, address _glpUtilsAddress, address _poolCommitterAddress, address _usdcAddress) {
    glpExchange = IExchange(_glpExchangeAddress);
    priceUtils = IPriceUtils(_priceUtilsAddress);
    glpUtils = IGlpUtils(_glpUtilsAddress);
    poolCommitter = IPoolCommitter(_poolCommitterAddress);
    usdcToken = ERC20(_usdcAddress);
  }

  function positionWorth() override public view returns (uint256) {
    uint256 glpPrice = priceUtils.glpPrice();
    return (tokenAmount * glpPrice / GLP_MULTIPLIER);
  }

  function costBasis() override public view returns (uint256) {
    return _costBasis;
  }

  function buy(uint256 usdcAmount) override external returns (uint256) {
    usdcToken.transferFrom(msg.sender, address(this), usdcAmount);
    usdcToken.approve(address(glpExchange), usdcAmount);
    Purchase memory purchase = glpExchange.buy(usdcAmount);
    _costBasis += purchase.usdcAmount;
    tokenAmount += purchase.tokenAmount;  
    return purchase.tokenAmount;
  }

  function sell(uint256 usdcAmount) override external returns (uint256) {
    usdcToken.transferFrom(msg.sender, address(this), usdcAmount);
    usdcToken.approve(address(glpExchange), usdcAmount);
    Purchase memory purchase = glpExchange.buy(usdcAmount);
    _costBasis += purchase.usdcAmount;
    tokenAmount += purchase.tokenAmount;  
    return purchase.tokenAmount;
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
  }

  function price() override external view returns (uint256) {
    return priceUtils.glpPrice();
  }

  function setGlpTokens(address[] memory _glpTokens) external onlyOwner() {
    glpTokens = _glpTokens;
  }
}
