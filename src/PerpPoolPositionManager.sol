// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IPositionManager} from "src/IPositionManager.sol";
import {IExchange,Purchase} from "src/IExchange.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {TokenExposure} from "src/TokenExposure.sol";
import {PriceUtils} from "src/PriceUtils.sol";
import {ILeveragedPool} from "perp-pool/ILeveragedPool.sol";
import {IPoolCommitter} from "perp-pool/IPoolCommitter.sol";
import {PerpPoolUtils} from "src/PerpPoolUtils.sol";
import {TokenAllocation} from "src/TokenAllocation.sol";
import {PositionType} from "src/PositionType.sol";

contract PerpPoolPositionManager is IPositionManager {
  IExchange private perpPoolExchange;
  ERC20 private poolToken;
  PriceUtils private priceUtils;
  ILeveragedPool private leveragedPool;
  IPoolCommitter private poolCommitter;
  ERC20 private usdcToken; 
  PerpPoolUtils private perpPoolUtils;
  
  uint256 private _costBasis;
  address private trackingTokenAddress;
  uint256 private lastIntervalId;

	constructor(address _perpPoolExchangeAddress,  address _poolTokenAddress, address _priceUtilsAddress, address _leveragedPoolAddress, address _trackingTokenAddress, address _poolCommitterAddress, address _usdcAddress, address _perpPoolUtilsAddress) {
    perpPoolExchange = IExchange(_perpPoolExchangeAddress);
    poolToken = ERC20(_poolTokenAddress);
    priceUtils = PriceUtils(_priceUtilsAddress);
    leveragedPool = ILeveragedPool(_leveragedPoolAddress);
    trackingTokenAddress = _trackingTokenAddress;
    poolCommitter = IPoolCommitter(_poolCommitterAddress);
    usdcToken = ERC20(_usdcAddress);
    perpPoolUtils = PerpPoolUtils(_perpPoolUtilsAddress);
  }

  function positionWorth() override public view returns (uint256) {
    uint256 claimedUsdcWorth = perpPoolUtils.getClaimedUsdcWorth(address(this), address(leveragedPool));
    uint256 committedUsdcWorth = perpPoolUtils.getCommittedUsdcWorth(address(perpPoolExchange));

    return claimedUsdcWorth + committedUsdcWorth;
  }

  function costBasis() override public view returns (uint256) {
    return _costBasis; 
  }
  function pnl() override external view returns (int256) {
    return int256(positionWorth()) - int256(costBasis());
  }

  function buy(uint256 usdcAmount) override external returns (uint256) {
    usdcToken.transferFrom(msg.sender, address(this), usdcAmount);
    usdcToken.approve(address(perpPoolExchange), usdcAmount);

    Purchase memory purchase = perpPoolExchange.buy(usdcAmount);
    _costBasis += purchase.usdcAmount;
    return purchase.tokenAmount;
  }

  function sell(uint256 usdcAmount) override external returns (uint256) {
    usdcToken.transferFrom(msg.sender, address(this), usdcAmount);
    usdcToken.approve(address(perpPoolExchange), usdcAmount);

    Purchase memory purchase = perpPoolExchange.buy(usdcAmount);
    _costBasis += purchase.usdcAmount;
    return purchase.tokenAmount;
  }

  function exposures() override external view returns (TokenExposure[] memory) {
    TokenExposure[] memory tokenExposures = new TokenExposure[](1);
    tokenExposures[0] = TokenExposure({
      amount: -1 * int256(positionWorth()) * 3,
      token: trackingTokenAddress      
    });
  }

  function allocation() override external view returns (TokenAllocation[] memory) {
    TokenAllocation[] memory tokenAllocations = new TokenAllocation[](1);
    tokenAllocations[0] = TokenAllocation({
      tokenAddress: trackingTokenAddress,
      percentage: 100000,
      leverage: 3
    });
  }

  function price() override external view returns (uint256) {
    return priceUtils.perpPoolTokenPrice(address(leveragedPool), PositionType.Short);
  }
}